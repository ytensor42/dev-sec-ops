# ECS

## `python-webapp` Service

- Prerequisite
    - ECR VPC Endpoint
        - `default` VPC private subnet
- IAM role
    - Name: python-webapp1-ECSTaskExecutionRole
        - arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
- Security Groups
    - default-sg-ecs-alb
    - default-sg-ecs-service
- ECS configuration
    - Cluster: python-webapp1-fargate-cluster
    - Task: default-task-python-webapp1
        - port 5000:5000:tcp
    - Service: default-svc-ecs-fargate
- ALB
    - Name: default-alb-python-webapp1-ecs
    - TG: default-tg-python-webapp1-ecs
        - port 5000
    - Listener: https
        - port 443
    - FQDN: python-webapp1.aws.ansolute.com

### Screenshots
- `/`
    ![`/`]()
- `/version`
    ![`/version`]()
---