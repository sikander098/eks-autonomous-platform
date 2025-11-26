# Troubleshooting Guide

## Issue 1: Karpenter Nodes "NotReady" or Invisible
**Symptom:** Logs show `launched nodeclaim`, but `kubectl get nodes` does not show the new IP.
**Root Cause:** The IAM Role for the nodes is not mapped in the `aws-auth` ConfigMap.
**Fix:**
```bash
eksctl create iamidentitymapping --username system:node:{{EC2PrivateDNSName}} ...
```

## Issue 2: Helm Schema Validation Error
**Symptom:** ArgoCD Sync Failed with `values don't meet the specifications of the schema`.
**Root Cause:** The OpenTelemetry Helm Chart v0.38+ enforces strict CamelCase and prevents root-level overrides for sub-charts.
**Fix:** We utilized the "Wrapper Chart" pattern with a minimized `values.yaml` and relied on Post-Install patching for specific database node selectors.

## Issue 3: Kyverno Install Failed (managedFields)
**Symptom:** `metadata.managedFields must be nil`.
**Root Cause:** "Zombie" CRDs left over from a failed Helm install.
**Fix:** Manually deleted all CRDs and Webhooks, then installed via Raw Manifests to bypass Helm corruption.
