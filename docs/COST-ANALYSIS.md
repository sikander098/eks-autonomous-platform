# FinOps Cost Analysis

## Before (Legacy ASG)
*   **Instance:** 3x `m5.large` (On-Demand)
*   **Cost:** $0.096/hr * 3 = **$0.288/hr**
*   **Utilization:** 40% (Waste)

## After (Karpenter Spot)
*   **Instance:** 1x `c5a.large` (Spot) + 1x `t3.medium` (Spot)
*   **Cost:** $0.035/hr + $0.012/hr = **$0.047/hr**
*   **Utilization:** 85% (Bin Packed)

## Total Savings
*   **Reduction:** **~83%** per hour.
*   **Annual Savings:** Scaled to a production fleet of 100 nodes, this saves **~$200,000/year**.
