# Deprecated: Custom Auto-Heal Webhook

## Overview
We initially attempted to build a custom Python Flask application to listen to Prometheus Alerts and cordon nodes via the Kubernetes API.

## Why we deprecated it
1.  **Complexity:** Required maintaining custom code, Dockerfiles, and RBAC.
2.  **Race Conditions:** If two alerts fired, the script often crashed.
3.  **Reinventing the Wheel:** We realized `Node Problem Detector` and `Karpenter` handle this natively at the kernel level.

## Status
**Archived.** Replaced by Karpenter Native Interruption Handling.
