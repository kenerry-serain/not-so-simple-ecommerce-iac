resource "aws_sqs_queue" "nsse" {
  count = length(var.queues)

  name                      = var.queues[count.index].name
  delay_seconds             = var.queues[count.index].delay_seconds
  max_message_size          = var.queues[count.index].max_message_size
  message_retention_seconds = var.queues[count.index].message_retention_seconds
  receive_wait_time_seconds = var.queues[count.index].receive_wait_time_seconds
  sqs_managed_sse_enabled   = var.queues[count.index].sqs_managed_sse_enabled
  policy                    = data.aws_iam_policy_document.sqs_policy.json

  tags = var.tags
}

resource "aws_sqs_queue_redrive_policy" "nsse" {
  count = length(aws_sqs_queue.nsse)

  queue_url = aws_sqs_queue.nsse[count.index].id
  redrive_policy = jsonencode({
    deadLetterTargetArn = one([
      for queue in aws_sqs_queue.deadletter : queue.arn
    if startswith(queue.name, aws_sqs_queue.nsse[count.index].name)])
    maxReceiveCount = 2
  })
}

