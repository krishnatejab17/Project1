Concurrency:
concurrency is a powerful keyword used in GitHub Actions workflows to manage how jobs or entire workflow runs execute when triggered multiple times in rapid succession.
It prevents multiple runs from working on the same task simultaneously, which helps avoid conflicts like:
Multiple deployments trying to update the same production environment at the same time.
Two builds attempting to use the same shared resource or artifact storage.

name: Docker CI Pipeline

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    
    # This is the line in question:
    concurrency: ci-${{ github.repository }}-docker-pipeline

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Build Docker image
        run: docker build . --tag my-image:latest

      - name: Push Docker image (hypothetical step)
        run: echo "Pushing image to registry..."


Run 1: A push is made to main. A new workflow run starts and is assigned to the above pipeline. 
It begins executing the build job.
Run 2: One second later, another push is made to main while Run 1 is still building. The new Run 2 attempts to use the same concurrency group name.
Result: Because a job with this exact key is already active, the GitHub Actions runner will queue Run 2 and wait for Run 1 to finish completely before starting the second job.

#########################################################################################################################
Instead of using seperate data block we can use the below inline policy
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
#########################################################################################################################
