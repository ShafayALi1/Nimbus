# 2. kind locally, EKS only in short paid sessions

**Decision:** develop and practise on kind (Kubernetes in Docker). The same Helm charts and Argo CD apps would run on EKS.
**Why:** free, rebuilt in 10 minutes, safe to break. EKS costs ~0.10 USD/h for the control plane alone.
**Trade-off:** no real cloud load balancer, IAM or multi-AZ on kind. Those are learned with Terraform on LocalStack and one planned AWS session.
