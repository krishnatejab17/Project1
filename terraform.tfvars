aws_region = "us-east-1"
repository_name = "project1-repo"
image_tag_mutability = "IMMUTABLE"
encryption_type = "KMS"
lifecycle_policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire untagged images older than 30 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF

app_name = "project1"
app_environment = "development"
public_subnets = ["10.10.0.0/25", "10.10.0.128/25"]
availability_zones = ["us-east-1a", "us-east-1b"] 
image_tag = "latest"
