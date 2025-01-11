resource "aws_iam_role_policy_attachment" "sqs" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  role       = aws_iam_role.instance_role.name
}