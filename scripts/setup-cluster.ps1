<#
.SYNOPSIS
    Bootstraps the EKS Cluster with OIDC and Karpenter Prerequisites.
.DESCRIPTION
    1. Creates EKS Cluster (if missing).
    2. Associates OIDC Provider.
    3. Creates IAM Roles for Karpenter Controller (IRSA).
    4. Creates IAM Roles for Worker Nodes.
    5. Updates aws-auth to allow Karpenter nodes to join.
    6. Tags Subnets for discovery.
#>

$ClusterName = "auto-heal"
$Region = "us-east-1"
$KarpenterNamespace = "kube-system"

Write-Host "🚀 Starting Infrastructure Bootstrap for $ClusterName..." -ForegroundColor Cyan

# 1. Check/Create Cluster
$ClusterStatus = aws eks describe-cluster --name $ClusterName --region $Region --query "cluster.status" --output text 2>$null
if ($ClusterStatus -ne "ACTIVE") {
    Write-Host "Creating Cluster (This takes ~15 mins)..."
    eksctl create cluster --name $ClusterName --region $Region --node-type t3.medium --nodes 2 --with-oidc
} else {
    Write-Host "✅ Cluster exists and is Active." -ForegroundColor Green
}

# 2. Get Account ID
$AccountId = aws sts get-caller-identity --query Account --output text

# 3. Create Karpenter Node Role (The instance profile for worker nodes)
Write-Host "Creating Karpenter Node Role via CloudFormation..."
aws cloudformation deploy `
  --stack-name "Karpenter-${ClusterName}" `
  --template-file "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v1.0.0/website/content/en/preview/getting-started/getting-started-with-karpenter/cloudformation.yaml" `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameter-overrides "ClusterName=${ClusterName}" `
  --region $Region

# 4. Create Karpenter Controller Role (IRSA)
Write-Host "Creating Karpenter Controller Service Account..."
eksctl create iamserviceaccount `
  --cluster $ClusterName `
  --region $Region `
  --name karpenter `
  --namespace $KarpenterNamespace `
  --role-name "${ClusterName}-karpenter" `
  --attach-policy-arn "arn:aws:iam::${AccountId}:policy/KarpenterControllerPolicy-${ClusterName}" `
  --role-only `
  --approve

# 5. Tag Subnets (Crucial for Karpenter Discovery)
Write-Host "Tagging VPC Subnets..."
$VpcId = aws eks describe-cluster --name $ClusterName --region $Region --query "cluster.resourcesVpcConfig.vpcId" --output text
$Subnets = aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VpcId" --query "Subnets[].SubnetId" --output text --region $Region
$SubnetArray = $Subnets -split "`t"
foreach ($Subnet in $SubnetArray) {
    if ($Subnet.Trim()) {
        aws ec2 create-tags --resources $Subnet --tags Key="karpenter.sh/discovery",Value=$ClusterName --region $Region
    }
}

# 6. Identity Mapping (The "Fix" for nodes not joining)
Write-Host "Applying Identity Mapping for Nodes..."
$NodeRoleArn = "arn:aws:iam::${AccountId}:role/KarpenterNodeRole-${ClusterName}"
eksctl create iamidentitymapping `
  --cluster $ClusterName `
  --region $Region `
  --arn $NodeRoleArn `
  --group system:bootstrappers `
  --group system:nodes `
  --username 'system:node:{{EC2PrivateDNSName}}'

Write-Host "✅ Cluster Setup Complete. Ready for ArgoCD." -ForegroundColor Green
