##############################################
# OIDC provider for GitHub Actions
##############################################

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  # The client ID must be "sts.amazonaws.com" to allow role assumption via OIDC
  client_id_list = ["sts.amazonaws.com"]

  # GitHub's CA thumbprint (this is correct as of now, but always verify)
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

##############################################
# IAM Role for GitHub Actions (OIDC)
##############################################

resource "aws_iam_role" "github_actions_oidc_role" {
  name = "github-actions-oidc-role"

  # Trust relationship for GitHub Actions to assume the role
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
            # Ensure this is your correct GitHub repository and branch
            "token.actions.githubusercontent.com:sub" = "repo:krishnatejab17/Project1:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

# Attach your custom combined policy to GitHub Actions role
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
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWS managed ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach your custom combined policy to ECS Task Execution Role
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_custom" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.github_actions_policy_combined.arn
}

##############################################
# Custom Combined Policy for GitHub Actions
##############################################

resource "aws_iam_policy" "github_actions_policy_combined" {
  name        = "github-actions-combined-policy"
  description = "Complete permissions for Terraform backend + ECS + ECR deployment"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      # FULL S3 access (Terraform backend)
      {
        Effect   = "Allow",
        Action   = "s3:*",
        Resource = "*"
      },

      # IAM Read-only
      {
        Effect   = "Allow",
        Action   = [
          "iam:Get*",
          "iam:List*"
        ],
        Resource = "*"
      },

      # ECR access
      {
        Effect   = "Allow",
        Action   = "ecr:*",
        Resource = "*"
      },

      # ECS access
      {
        Effect   = "Allow",
        Action   = "ecs:*",
        Resource = "*"
      },

      # PassRole for ECS tasks
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
        Effect   = "Allow",
        Action   = [
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "application-autoscaling:*"
        ],
        Resource = "*"
      },

      # Route53
      {
        Effect   = "Allow",
        Action   = [
          "route53:ListHostedZones",
          "route53:GetHostedZone",
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets"
        ],
        Resource = "*"
      },

      # ACM
      {
        Effect   = "Allow",
        Action   = [
          "acm:DescribeCertificate",
          "acm:ListCertificates"
        ],
        Resource = "*"
      }
    ]
  })
}
