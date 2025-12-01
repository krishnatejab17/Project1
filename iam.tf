############################################################
# ECS Task Execution Role
############################################################
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "project1-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json

  tags = {
    Name        = "project1-iam-role"
    Environment = "development"
  }
}

data "aws_iam_policy_document" "ecs_assume" {
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

############################################################
# GitHub Actions OIDC Identity Provider
############################################################
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

############################################################
# GitHub Actions OIDC Role
############################################################
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
            # IMPORTANT: repo must match exactly
            "token.actions.githubusercontent.com:sub" = "repo:krishnatejab17/Project1:*"
          }
        }
      }
    ]
  })
}

############################################################
# Combined GitHub Actions Policy (ALL NEEDED PERMISSIONS)
############################################################
resource "aws_iam_policy" "github_actions_policy_combined" {
  name        = "github-actions-combined-policy"
  description = "Complete permissions for Terraform backend + ECS + ECR deployment"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      ##################################################
      # 🔥 FULL S3 ACCESS (Terraform backend)
      ##################################################
      {
        Effect = "Allow",
        Action = "s3:*",
        Resource = "*"
      },

      ##################################################
      # IAM READ ACCESS (Fixes ListRolePolicies / Get*)
      ##################################################
      {
        Effect = "Allow",
        Action = [
          "iam:Get*",
          "iam:List*"
        ],
        Resource = "*"
      },

      ##################################################
      # ECR Access (push images)
      ##################################################
      {
        Effect = "Allow",
        Action = "ecr:*",
        Resource = "*"
      },

      ##################################################
      # ECS Access (deploy new task definitions)
      ##################################################
      {
        Effect = "Allow",
        Action = "ecs:*",
        Resource = "*"
      },

      ##################################################
      # iam:PassRole for ECS tasks
      ##################################################
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = "*"
      },

      ##################################################
      # CloudWatch Logs
      ##################################################
      {
        Effect = "Allow",
        Action = "logs:*",
        Resource = "*"
      },

      ##################################################
      # VPC, Subnets, SG, ELB, Autoscaling (Terraform needs all)
      ##################################################
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

############################################################
# Attach Combined Policy to OIDC Role
############################################################
resource "aws_iam_role_policy_attachment" "combined_attach" {
  role       = aws_iam_role.github_actions_oidc_role.name
  policy_arn = aws_iam_policy.github_actions_policy_combined.arn
}
