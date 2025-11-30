# Project1
Using ECS Fargate deploy app
Whenever code is pushed to GitHub, a Docker image should be created. 
Docker image should be pushed to ECR
That Docker image from ECR should then be deployed to ECS Fargate. 
And the deployed service should have a load balancer. 
When I hit the load balancer DNS, it should respond with 'welcome'.




Noes:
aws sts get-caller-identity  to get aws account ID 

#Authenticate AWS ECR with docker
aws ecr get-login-password --region us-east-1   | docker login --username AWS --password-stdin 828411126532.dkr.ecr.us-east-1.amazonaws.com

