resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2-S3-Profile"
  role = "EC2-S3-ReadOnly"
}