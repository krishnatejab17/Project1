###############################################
# ECS Task Execution Role
###############################################
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "project1-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    Name        = "project1-iam-role"
    Environment = "development"
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
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

###############################################
# GitHub Actions OIDC Role
###############################################
resource "aws_iam_role" "github_actions_oidc_role" {
  name = "github-actions-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            # IMPORTANT — must match your repo!
            "token.actions.githubusercontent.com:sub" = "repo:krishnatejab17/Project1:*"
          }
        }
      }
    ]
  })
}

###############################################
# Single Combined Policy (clean + correct)
###############################################
resource "aws_iam_policy" "github_actions_policy_combined" {
  name        = "github-actions-combined-policy"
  description = "Full permissions required for Terraform + ECS/ECR deployment"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      #########################################
      # 🔥 FULL S3 ACCESS (Fixes all 403 errors)
      #########################################
      {
        Effect = "Allow",
        Action = "s3:*",
        Resource = "*"
      },

      #########################################
      # ECR Full Access
      #########################################
      {
        Effect = "Allow",
        Action = "ecr:*",
        Resource = "*"
      },

      #########################################
      # ECS Full Access
      #########################################
      {
        Effect = "Allow",
        Action = "ecs:*",
        Resource = "*"
      },

      #########################################
      # Allow IAM PassRole (needed for ECS)
      #########################################
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole",
          "iam:GetRole",
          "iam:ListRoles"
        ],
        Resource = "*"
      },

      #########################################
      # CloudWatch Logs
      #########################################
      {
        Effect = "Allow",
        Action = "logs:*",
        Resource = "*"
      },

      #########################################
      # VPC / Networking / Load Balancer
      #########################################
      {
        Effect = "Allow",
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "application-autoscaling:*"
        ],
        Resource = "*"
      }
    ]
  })
}

###############################################
# Attach final combined policy
###############################################
resource "aws_iam_role_policy_attachment" "combined_attach" {
  role       = aws_iam_role.github_actions_oidc_role.name
  policy_arn = aws_iam_policy.github_actions_policy_combined.arn
}
