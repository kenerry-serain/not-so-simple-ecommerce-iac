resource "aws_iam_role_policy_attachment" "ses" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
  role       = aws_iam_role.instance_role.name
}