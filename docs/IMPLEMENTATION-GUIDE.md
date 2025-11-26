# Implementation Guide

This document outlines the step-by-step process to reproduce the **EKS Self-Healing Platform**.

## 🛠 Prerequisites
Ensure you have the following tools installed:
*   `aws-cli` (v2.0+)
*   `eksctl` (v0.175+)
*   `kubectl` (v1.29+)
*   `helm` (v3.0+)
*   `argocd-cli` (Optional, for local management)

## Phase 1: Infrastructure Bootstrap (Duration: ~20 mins)
We use a PowerShell script to automate the "undifferentiated heavy lifting" of IAM roles and VPC tagging.

1.  **Run the Setup Script:**
    ```powershell
    ./scripts/setup-cluster.ps1
    ```
2.  **Verify Access:**
    ```bash
    kubectl get nodes
    # Should show 2 default nodes (Ready)
    ```

## Phase 2: GitOps Initialization (Duration: ~5 mins)
We install ArgoCD to act as the control plane for all subsequent deployments.

1.  **Install ArgoCD:**
    ```bash
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ```
2.  **Connect to GitHub:**
    *   Port forward the UI: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
    *   Log in and create the "App of Apps" or connect the `infra` and `apps` folders from this repository.

## Phase 3: Workload Deployment
Once ArgoCD is synced:
1.  **Karpenter (Infra):** ArgoCD syncs `/infra`. This installs the Karpenter controller and applies the Default (Spot) and Critical (On-Demand) NodePools.
2.  **OpenTelemetry (App):** ArgoCD syncs `/apps/astronomy-shop`. This pulls the upstream helm chart.

## Phase 4: Database Patching (Crucial Step)
Due to strict schema validation in the OTel Helm chart, we cannot configure the database node selectors purely via Git without breaking the chart. We use a "Live Patch" strategy.

1.  **Run the Patch Script:**
    ```powershell
    ./scripts/patch-databases.ps1
    ```
2.  **Verify:**
    Check that `valkey`, `postgres`, and `kafka` pods are restarting on nodes labeled `capacity-type: on-demand`.

## Phase 5: Verification
To prove the system works:
1.  **Scale Up:** `kubectl scale deployment frontend -n astronomy --replicas=50`
2.  **Check Nodes:** `kubectl get nodes -L karpenter.sh/capacity-type`
    *   *Expected:* New nodes appear with `SPOT` capacity type.
