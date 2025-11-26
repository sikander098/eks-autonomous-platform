# System Architecture

## Overview
This platform utilizes a Controller-based design pattern to manage infrastructure lifecycle events autonomously.

## Design Decisions

### 1. Karpenter vs. Cluster Autoscaler
| Feature | Cluster Autoscaler (Legacy) | Karpenter (Modern) |
| :--- | :--- | :--- |
| **Mechanism** | Scales ASGs (Groups) | Direct EC2 Fleet API |
| **Speed** | 3-5 Minutes | < 45 Seconds |
| **Decision** | Constraints of ASG | Bin Packing (Tetris) |
| **Cost** | High (Over-provisioning) | Low (Right-sizing) |

**Decision:** We chose Karpenter to achieve aggressive consolidation and Spot instance leverage.

### 2. Hybrid Spot Strategy
Running databases on Spot is reckless. Running frontends on On-Demand is wasteful.
*   **Solution:** We implemented a Tainted NodePool strategy.
*   **Critical:** `tier: critical` label forces On-Demand.
*   **Default:** Everything else falls through to Spot.

### 3. GitOps Workflow
We moved from Imperative (`kubectl apply`) to Declarative (ArgoCD).
*   **Benefit:** Disaster Recovery. We can rebuild the cluster in 15 minutes from this repo.
*   **Benefit:** Audit Trail. Every change is a Git Commit.
