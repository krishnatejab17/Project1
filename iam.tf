##############################################
# OIDC provider for GitHub Actions
##############################################

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

##############################################
# IAM Role for GitHub Actions (OIDC)
##############################################

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
            "token.actions.githubusercontent.com:sub" = "repo:krishnatejab17/*"
          }
        }
      }
    ]
  })
}

# Attach policy to GitHub OIDC Role
resource "aws_iam_role_policy_attachment" "combined_attach" {
  role       = aws_iam_role.github_actions_oidc_role.name
  policy_arn = aws_iam_policy.github_actions_policy_combined.arn
}

##############################################
# ECS Task Execution Role
##############################################

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWS managed ECS execution policy
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach custom policy to ECS task execution role
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_custom" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.github_actions_policy_combined.arn
}

##############################################
# Custom IAM Policy (GitHub Actions)
##############################################

resource "aws_iam_policy" "github_actions_policy_combined" {
  name        = "github-actions-combined-policy"
  description = "Complete permissions for Terraform backend + ECS + ECR + Route53 + ACM deployment"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      # S3 (Terraform backend)
      {
        Effect   = "Allow",
        Action   = "s3:*",
        Resource = "*"
      },

      # IAM (read-only)
      {
        Effect = "Allow",
        Action = [
          "iam:Get*",
          "iam:List*"
        ],
        Resource = "*"
      },

      # ECR
      {
        Effect   = "Allow",
        Action   = "ecr:*",
        Resource = "*"
      },

      # ECS
      {
        Effect   = "Allow",
        Action   = "ecs:*",
        Resource = "*"
      },

      # PassRole (required by ECS tasks)
      {
        Effect   = "Allow",
        Action   = ["iam:PassRole"],
        Resource = "*"
      },

      # CloudWatch Logs
      {
        Effect   = "Allow",
        Action   = "logs:*",
        Resource = "*"
      },

      # Networking + Load Balancers + Autoscaling
      {
        Effect = "Allow",
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "application-autoscaling:*"
        ],
        Resource = "*"
      },

      # Route53
      {
        Effect = "Allow",
        Action = [
          "route53:ListHostedZones",
          "route53:GetHostedZone",
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets",
          "route53:ListTagsForResource"
        ],
        Resource = "*"
      },

      # ACM
      {
        Effect = "Allow",
        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:ListTagsForCertificate",
          "acm:GetCertificate"
        ],
        Resource = "*"
      }
    ]
  })
}
