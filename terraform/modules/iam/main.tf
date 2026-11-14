# Least privilege: the orders-api role may read exactly one secret and nothing else.
# On EKS the role is assumed by the pod's service account (IRSA): no access keys anywhere.
data "aws_iam_policy_document" "assume" {
  statement {
    actions = var.oidc_provider_arn == null ? ["sts:AssumeRole"] : ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = var.oidc_provider_arn == null ? "Service" : "Federated"
      identifiers = var.oidc_provider_arn == null ? ["ec2.amazonaws.com"] : [var.oidc_provider_arn]
    }
  }
}

data "aws_iam_policy_document" "read_db_secret" {
  statement {
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [var.db_secret_arn]
  }
}

resource "aws_iam_role" "orders_api" {
  name               = "${var.name}-orders-api"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy" "read_db_secret" {
  name   = "read-db-secret"
  role   = aws_iam_role.orders_api.id
  policy = data.aws_iam_policy_document.read_db_secret.json
}
