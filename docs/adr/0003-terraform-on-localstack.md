# 3. Terraform against LocalStack 4.14, pinned

**Decision:** practise Terraform on LocalStack, pinned to 4.14.
**Why:** since March 2026 newer LocalStack images need an account and token, and ECR/RDS/EKS were never free there. 4.14 is the last image that runs without either, and it covers VPC, IAM, S3, DynamoDB and Secrets Manager.
**Trade-off:** frozen version with no security updates (fine for a local emulator). Paid-only services live in `envs/aws-dev`. Alternative: Floci (MIT) on the same port.
