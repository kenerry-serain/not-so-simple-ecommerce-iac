resource "aws_iam_role" "order_confirmed_lambda_role" {
  name               = var.lambda_order_confirmed.role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "order_confirmed_lambda_policy" {
  name        = var.lambda_order_confirmed.policy_name
  description = "Policy for Lambda"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "secretsmanager:GetSecretValue",
        "sns:Publish",
      ],
      Resource = [
        aws_rds_cluster.this.master_user_secret[0].secret_arn,
        aws_sns_topic.order_confirmed_topic.arn
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "order_confirmed_lambda_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.order_confirmed_lambda_role.name
}

resource "aws_iam_role_policy_attachment" "order_confirmed_lambda_custom" {
  policy_arn = aws_iam_policy.order_confirmed_lambda_policy.arn
  role       = aws_iam_role.order_confirmed_lambda_role.name
}