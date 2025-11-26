# Self-Healing, Cost-Optimized EKS Platform 🚀

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![ArgoCD](https://img.shields.io/badge/ArgoCD-%23EF7B4D.svg?style=for-the-badge&logo=argo&logoColor=white)
![Karpenter](https://img.shields.io/badge/Karpenter-v1.0-blue)

## 📖 Executive Summary

This project represents a **production-grade Platform Engineering architecture** on Amazon EKS. It addresses the "Trilemma" of Cloud Infrastructure: **Speed, Cost, and Reliability**.

Moving away from legacy Auto Scaling Groups (ASGs), this platform utilizes **Karpenter** for sub-minute node provisioning and **ArgoCD** for GitOps-driven delivery. It achieves **~80% cost reduction** by intelligently orchestrating stateless workloads onto Spot Instances while protecting stateful databases on On-Demand capacity.

### Architecture Diagram
```ascii
[ Users ] -> [ Load Balancer ]
      │
      ▼
[ EKS Cluster ] ─────────────────────────────────────────────────┐
│                                                                │
│  [ ArgoCD (GitOps) ] <── syncs ── [ GitHub Repo ]              │
│         │                                                      │
│         ▼                                                      │
│  [ OpenTelemetry App ]                                         │
│    ├── Frontend (Spot Nodes) ◄──────┐                          │
│    └── Redis/DB (On-Demand)  ◄──────┼── [ Karpenter ]          │
│                                     │        │                 │
│  [ Prometheus/Grafana ] ◄── stats ──┘        │ (Provisioning)  │
│                                              ▼                 │
│  [ Kyverno (Policy) ] ── guards ──>     [ AWS EC2 Fleet ]      │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### 🛑 The Problem
Legacy EKS scaling using Cluster Autoscaler suffers from:
*   **Slow Scale-Up:** 3-5 minute boot times waiting for ASGs.
*   **Cost Inefficiency:** Difficulty running 100% Spot instances safely.
*   **Operational Toil:** Manual kubectl deployments leading to configuration drift.

### ✅ The Solution
A fully automated, self-healing platform featuring:
*   **Hybrid Compute Strategy:** Split NodePools for Spot (Cheap) and On-Demand (Safe).
*   **Just-in-Time Scaling:** Nodes provisioned in <45 seconds based on exact pod requirements.
*   **Deep Observability:** End-to-end distributed tracing from user click to database query.
*   **Governance:** Policy-as-Code preventing expensive or insecure deployments.

### 🏆 Key Achievements
*   **80% Cost Reduction:** Verified via Grafana dashboards tracking Spot usage.
*   **Zero-Touch Recovery:** Automated handling of AWS Spot Interruption Warnings (2-minute drain).
*   **GitOps Maturity:** Full synchronization of Infrastructure and Applications via ArgoCD.

### 🛠 Tech Stack
*   **Orchestration:** Amazon EKS v1.29
*   **Scaling:** Karpenter v1.0
*   **GitOps:** ArgoCD v2.10
*   **Observability:** Prometheus, Grafana, OpenTelemetry, Jaeger
*   **Governance:** Kyverno v3.2

### 🚀 Quick Start
**Prerequisites:** AWS CLI configured, kubectl, helm, eksctl.

1.  **Bootstrap Cluster:**
    ```bash
    ./scripts/setup-cluster.ps1
    ```
2.  **Deploy Infrastructure (ArgoCD):**
    Connect ArgoCD to this repo and sync the `infra` directory.
3.  **Deploy Workload (ArgoCD):**
    Sync the `apps/astronomy-shop` directory.
4.  **Verify:**
    ```bash
    kubectl get nodes -L karpenter.sh/capacity-type
    ```

### 📸 Screenshots
(See /screenshots folder for high-res proofs)
*   **Hybrid Nodes:** Terminal showing mixed Spot/On-Demand capacity.
*   **ArgoCD Tree:** Visualizing the distributed system state.
*   **Jaeger Trace:** A waterfall graph of a request latency.

### 🤝 Contributing
See CONTRIBUTING.md for pull request guidelines.

### 📄 License
MIT License. See LICENSE file.
