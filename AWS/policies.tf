resource "aws_iam_policy" "povadmin" {
  name = "povadmin_pol"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "sqs:*"
            ],
            "Resource": [
                "arn:aws:s3:::cribl-pov-bucket/*",
                "arn:aws:sqs:us-west-2:243602015558:cribl-pov-bucket"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::cribl-pov-bucket"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::cribl-pov-bucket/*"
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": "s3:GetBucketLocation",
            "Resource": "arn:aws:s3:::cribl-pov-bucket"
        },
        {
            "Sid": "VisualEditor4",
            "Effect": "Allow",
            "Action": "sqs:ListQueues",
            "Resource": "*"
        }
    ]
}
EOF
}

