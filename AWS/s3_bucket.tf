#Create AWS S3 Bucket
resource "aws_s3_bucket" "cribl-pov-bucket" {
  bucket        = "cribl-pov-bucket"
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_user_policy_attachment" "povadmin" {
  user       = var.username
  policy_arn = aws_iam_policy.povadmin.arn
}