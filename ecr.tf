resource "aws_ecr_repository" "aws_ecr" {
  name = "${var.repository_name}-${var.app_environment}-ecr"
  tags = {
    Environment = var.app_environment
  }
  image_tag_mutability = var.image_tag_mutability

  encryption_configuration {
    encryption_type = var.encryption_type
  }
}

resource "aws_ecr_lifecycle_policy" "aws_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.aws_ecr.name
  policy     = var.lifecycle_policy
}