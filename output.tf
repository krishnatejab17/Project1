output "ecr_repository_url" {
  value = aws_ecr_repository.project1.repository_url
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}