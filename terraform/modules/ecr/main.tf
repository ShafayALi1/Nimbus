resource "aws_ecr_repository" "this" {
  for_each             = toset(var.services)
  name                 = "nimbus/${each.key}"
  image_tag_mutability = "IMMUTABLE" # a tag (git SHA) always means the same image
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "keep_recent" {
  for_each   = aws_ecr_repository.this
  repository = each.value.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep the last 20 images"
      selection    = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 20 }
      action       = { type = "expire" }
    }]
  })
}
