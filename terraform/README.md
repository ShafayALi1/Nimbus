# Terraform (M1–M2)

Same modules for two worlds: `envs/local` on **LocalStack** (free) and `envs/aws-dev` on **real AWS** (paid, rare).

```
modules/network   VPC across 2 AZs: public + private subnets, internet gateway, optional NAT
modules/secrets   random DB password → Secrets Manager (nobody ever types it)
modules/iam       least-privilege role: read ONE secret; IRSA-ready for EKS
modules/ecr       image repos, immutable tags, scan on push            (aws-dev only)
modules/rds       PostgreSQL in private subnets, encrypted, optional multi-AZ (aws-dev only)
bootstrap/        S3 bucket (versioned) + DynamoDB table for remote state and locking
```

## Practise on LocalStack (WSL)

```bash
docker compose -f localstack/docker-compose.yml up -d
cd bootstrap && terraform init && terraform apply          # state bucket + lock table
cd ../envs/local && terraform init && terraform apply      # VPC, subnets, secret, IAM role
terraform plan                                             # must say "No changes" (no drift)
terraform destroy
```
Install Terraform in WSL: `sudo snap install terraform --classic`, or use OpenTofu (`tofu`), which works the same.

If LocalStack 4.14 ever stops working, use the free MIT-licensed `hectorvent/floci` image on the same port.

## Exercises (interview gold)
1. **Locking:** run `terraform apply` in two terminals at once. The second waits for the DynamoDB lock. Explain why.
2. **Drift:** change a tag on the VPC with `aws --endpoint-url http://localhost:4566 ec2 create-tags ...`, then `terraform plan`.
3. **State loss:** what happens if the state file is deleted? (Versioning on the bucket is the answer: restore the previous version.)
4. **NAT cost:** why is `enable_nat` false by default? What breaks in private subnets without it?
5. Draw the VPC from memory: 2 AZs, 4 subnets, 2 route tables, IGW.
