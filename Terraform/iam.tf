###############################################
# ECS Task Execution Role
###############################################
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.app_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    Name        = "${var.app_name}-iam-role"
    Environment = var.app_environment
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


###############################################
# GitHub OIDC Provider
###############################################
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}


###############################################
# GitHub Actions OIDC Role (Corrected)
###############################################
resource "aws_iam_role" "github_actions_oidc_role" {
  name = "github-actions-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRoleWithWebIdentity",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:krishnatejab17/Project1:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}


###############################################
# GitHub OIDC Role Permissions
###############################################

# ECR push/pull
resource "aws_iam_role_policy_attachment" "github_actions_ecr_policy" {
  role       = aws_iam_role.github_actions_oidc_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# ECS deploy
resource "aws_iam_role_policy_attachment" "github_actions_ecs_policy" {
  role       = aws_iam_role.github_actions_oidc_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSFullAccess"
}

# Terraform needs to create VPC/Subnets/Security Groups/ALB
resource "aws_iam_role_policy_attachment" "github_actions_vpc_policy" {
  role       = aws_iam_role.github_actions_oidc_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

# Terraform needs to create IAM roles (like ECS Task Role, Execution Role)
resource "aws_iam_role_policy_attachment" "github_actions_iam_policy" {
  role       = aws_iam_role.github_actions_oidc_role.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

# CloudWatch logs for ECS tasks
resource "aws_iam_role_policy_attachment" "github_actions_cloudwatch_policy" {
  role       = aws_iam_role.github_actions_oidc_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
