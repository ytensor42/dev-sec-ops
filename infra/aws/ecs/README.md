# ECS configuration
- IAM role
    - Name: webapp-ecsTaskExecutionRole
        - arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
- Security Groups
    - default-sg-ecs-alb
    - default-sg-ecs-task
- ECR VPC Endpoint
    - `default` VPC private subnet
- ECS configuration
    - Cluster: webapp-fargate-cluster
    - Task: default-task-webapp
        - port 5000:5000:tcp
    - Service: default-svc-ecs-fargate
- ALB
    - Name: default-alb-ecs
    - TG: default-tg-webapp-ecs
        - port 5000
    - Listener: http
        - port 80

## Screenshots
- `/`
    ![`/`](./alb-root.png)
- `/version`
    ![`/version`](./alb-version.png)
