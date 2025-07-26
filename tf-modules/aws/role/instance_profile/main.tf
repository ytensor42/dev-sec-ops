##
resource "aws_iam_role" "instance_role" {
  name = "instance-role-${var.name_postfix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each = toset(var.policy_arns)
  role = aws_iam_role.instance_role.name
  policy_arn = "${each.key}"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance-profile-${var.name_postfix}"
  role = aws_iam_role.instance_role.name
}