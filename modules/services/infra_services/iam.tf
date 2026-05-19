#Create a policy
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy

resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.cloud_env}_ec2_policy"
  path        = "/"
  description = "Policy to provide permission to EC2"
  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:Describe*",
          "s3:Get*"
        ],
        Resource = "*"
      }
    ]
  })
}

#Create a role
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role

# path.module is the filesystem path of the module where the expression is placed.
resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "${var.cloud_env}-ec2-role"
  assume_role_policy = "${file("${path.module}/assumerolepolicy.json")}"
}

#Attach role to policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "ec2_policy_role" {
  # name       = "${var.cloud_env}_ec2_attachment"
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn

  lifecycle {
    create_before_destroy = true
  }
}

#Attach role to an instance profile
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.cloud_env}-ec2-role"
  role = aws_iam_role.ec2_s3_access_role.name
}