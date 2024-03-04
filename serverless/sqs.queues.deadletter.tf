resource "aws_sqs_queue" "deadletter" {
  count = length(var.dlqueues)

  name                      = var.dlqueues[count.index].name
  delay_seconds             = var.dlqueues[count.index].delay_seconds
  max_message_size          = var.dlqueues[count.index].max_message_size
  message_retention_seconds = var.dlqueues[count.index].message_retention_seconds
  receive_wait_time_seconds = var.dlqueues[count.index].receive_wait_time_seconds
  sqs_managed_sse_enabled   = var.dlqueues[count.index].sqs_managed_sse_enabled
  policy                    = data.aws_iam_policy_document.sqs_policy.json

  tags = var.tags
}

resource "aws_sqs_queue_redrive_allow_policy" "deadletter" {
  count     = length(aws_sqs_queue.deadletter)
  queue_url = aws_sqs_queue.deadletter[count.index].id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns = [one([
      for queue in aws_sqs_queue.nsse : queue.arn
    if startswith(aws_sqs_queue.deadletter[count.index].name, queue.name)])]
  })
}
