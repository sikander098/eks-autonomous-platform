#!/bin/bash
# Chaos Engineering Script
# Simulates a "Greedy Developer" and "Scale Out"

echo "🧪 TEST 1: Attempting to deploy expensive pod (Should Fail)..."
kubectl run greedy-pod --image=nginx --requests=cpu=5
# Expected: Error from admission webhook

echo "🧪 TEST 2: Scaling Frontend to 50 replicas (Should Trigger Karpenter)..."
kubectl scale deployment frontend -n astronomy --replicas=50
# Expected: New Spot nodes appear in 'kubectl get nodes'
