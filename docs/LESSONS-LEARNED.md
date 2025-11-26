# Lessons Learned & Engineering Challenges

This project involved navigating complex interactions between AWS IAM, Kubernetes RBAC, and Helm schemas. Below are the key technical challenges and solutions.

## 1. The "Invisible Node" Problem (IAM Identity Mapping)
**Situation:** Karpenter was successfully provisioning EC2 instances (logs showed `launched nodeclaim`), but they never joined the cluster (`kubectl get nodes` did not show them).
**Task:** Diagnose the communication breakdown between the new nodes and the EKS Control Plane.
**Action:** I realized that while the EC2 instances had the correct IAM Role (`KarpenterNodeRole`), Kubernetes' `aws-auth` ConfigMap did not whitelist this role. The nodes were knocking on the door, but EKS was rejecting them.
**Result:** I updated the `aws-auth` map using `eksctl create iamidentitymapping`, adding the Karpenter role to the `system:bootstrappers` group. The nodes immediately joined the cluster and became Ready.

## 2. Helm Schema Validation Conflicts
**Situation:** We attempted to configure the OpenTelemetry Demo to use Spot Instances by overriding specific component settings in `values.yaml`.
**Task:** Deploy the application via ArgoCD without errors.
**Action:** The deployment failed because the upstream Helm Chart (v0.38.6) has strict schema validation that rejected our custom keys for `nodeSelector`.
**Result:** I pivoted to a **"Wrapper Chart" pattern**. I simplified the GitOps configuration to rely on Karpenter's default behavior (defaulting to Spot) and wrote a post-install patch script to force stateful databases onto On-Demand nodes. This bypassed the schema errors while achieving the desired architectural outcome.

## 3. Evolution from Webhook to Controller
**Situation:** Initially, I attempted to build a custom Python webhook to listen for Prometheus alerts and cordon nodes.
**Task:** Automate node remediation.
**Action:** I found the custom webhook approach to be brittle; handling race conditions and maintaining custom code was high-toil.
**Result:** I deprecated the webhook in favor of **Karpenter's native interruption handling**. Karpenter listens directly to the AWS SQS queue for Spot Interruption Warnings, providing a robust, event-driven solution with zero custom code maintenance.

## 4. GitOps Drift Management
**Situation:** During testing, I manually scaled the frontend deployment to 50 replicas to test Karpenter.
**Task:** Ensure the cluster state matches the source of truth.
**Action:** ArgoCD immediately detected the drift (Git said "1 replica", Cluster had "50") and reverted the change.
**Result:** This confirmed the value of GitOps for configuration enforcement. To perform the stress test, I had to temporarily disable Auto-Sync, verifying that the platform enforces state consistency by default.
