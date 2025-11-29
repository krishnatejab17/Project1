#create ECR repository
resource "aws_ecr_repository" "aws-ecr" {
  name                 = "${var.repository_name}-${var.app_environment}-ecr"
  tags = {
    Environment         = var.app_environment
  }
  image_tag_mutability = var.image_tag_mutability
  encryption_configuration {
    encryption_type = var.encryption_type
  }
}

resource "aws_ecr_lifecycle_policy" "aws-ecr-lifecycle-policy" {
  repository = aws_ecr_repository.aws-ecr.name
  policy     = var.lifecycle_policy
}

