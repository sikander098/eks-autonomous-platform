#!/usr/bin/env pwsh
# Idempotent Patch Script for OTel Databases
# Usage: ./patch-databases.ps1

Write-Host "🚀 Patching Databases to use On-Demand Nodes..."

# 1. Valkey (Redis)
kubectl patch deployment valkey-cart -n astronomy --type='merge' -p '{"spec":{"template":{"spec":{"nodeSelector":{"tier":"critical"}}}}}'

# 2. Postgres
kubectl patch deployment postgresql -n astronomy --type='merge' -p '{"spec":{"template":{"spec":{"nodeSelector":{"tier":"critical"}}}}}'

# 3. Kafka
kubectl patch deployment kafka -n astronomy --type='merge' -p '{"spec":{"template":{"spec":{"nodeSelector":{"tier":"critical"}}}}}'

# 4. OpenSearch
kubectl patch statefulset opensearch -n astronomy --type='merge' -p '{"spec":{"template":{"spec":{"nodeSelector":{"tier":"critical"}}}}}'

Write-Host "✅ Patching Complete. Watch Karpenter logs for On-Demand provisioning."
