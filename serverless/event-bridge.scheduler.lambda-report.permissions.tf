resource "aws_iam_role" "scheduler_execution_role" {
  name               = var.event_bridge_scheduler_lambda_report_job.role_name
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json
}

resource "aws_iam_policy" "invoke_lambda_policy" {
  name        = var.event_bridge_scheduler_lambda_report_job.policy_name
  description = "Policy for Lambda"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
       "lambda:InvokeFunction"
      ],
      Resource = [
        "*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eb_scheduler_lambda_invoke" {
  policy_arn = aws_iam_policy.invoke_lambda_policy.arn
  role       = aws_iam_role.scheduler_execution_role.name
}

