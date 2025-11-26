# Deployment Verification Checklist

## Infrastructure
- [ ] EKS Cluster is Active (v1.29+)
- [ ] OIDC Provider is associated
- [ ] Karpenter Controller is Running (`kubectl get pods -n kube-system`)
- [ ] NodePools are applied (`kubectl get nodepools`)

## Workloads
- [ ] ArgoCD Server is accessible
- [ ] `astronomy-shop` app is Synced and Healthy
- [ ] Frontend is accessible via LoadBalancer

## Validation
- [ ] **Hybrid Nodes:** `kubectl get nodes -L karpenter.sh/capacity-type` shows both SPOT and ON-DEMAND.
- [ ] **Policy:** `kubectl run greedy --requests=cpu=5` fails.
- [ ] **Scaling:** Scaling frontend triggers new Spot nodes.
