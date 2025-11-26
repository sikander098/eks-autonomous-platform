# Senior SRE Interview Cheat Sheet

## 30-Second Elevator Pitch
"I recently re-architected a Kubernetes platform to solve for Cost and Resilience. I migrated from legacy Auto Scaling Groups to Karpenter, reducing provisioning time by 80% (4m to 45s). I implemented a hybrid Spot/On-Demand strategy that saved 80% on compute costs, managed entirely via GitOps/ArgoCD, and governed by Policy-as-Code."

## The "Star" Story (Resilience)
*   **Situation:** We needed to run on Spot instances to save money, but couldn't risk downtime.
*   **Task:** Architect a self-healing mechanism.
*   **Action:** I deployed Karpenter and configured it to listen to AWS Interruption Events.
*   **Result:** I demonstrated (with logs) that when AWS reclaimed a node, our system automatically cordoned and drained the workload 2 minutes prior, resulting in zero 500 errors for users.

## Technical Deep Dive Questions
**Q: How does Karpenter handle Bin Packing?**
A: It looks at the aggregate CPU/RAM requests of pending pods and queries the EC2 Fleet API for the cheapest instance type that fits that specific sum, rather than relying on pre-defined node groups.

**Q: Why use ArgoCD over kubectl?**
A: To eliminate configuration drift. During testing, I manually scaled a deployment to 50 replicas. ArgoCD immediately detected the drift against Git and reverted it, proving the security of the platform.
