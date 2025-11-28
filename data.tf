#ECS will use this to assume the role (trust policy for ECS task execution role)

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

/*
data "aws_iam_policy_document" "ecs_task_assume" {

This is not creating anything.
It is generating a JSON policy document for the trust relationship.

Inside the policy:
🔸 statement {

A policy must have at least one statement.
This block represents one rule.

🔸 actions = ["sts:AssumeRole"]

This means:

👉 The service is allowed to assume (use) this IAM role.
sts:AssumeRole is required to let ECS tasks use the role.

🔸 principals {

Defines which AWS entity can use the role.

🔸 type = "Service"

It means the principal (requester) is an AWS Service.

🔸 identifiers = ["ecs-tasks.amazonaws.com"]

This says:

👉 ECS Tasks are allowed to assume this role.

So the trust policy basically means:
"Allow ECS Tasks to use this IAM role."*/