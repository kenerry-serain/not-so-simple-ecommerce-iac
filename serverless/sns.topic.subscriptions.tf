resource "aws_sns_topic_subscription" "order_confirmed" {
  count = length(var.order_confirmed_topic.subscriptions)

  topic_arn = aws_sns_topic.order_confirmed_topic.arn
  protocol  = "sqs"
  endpoint = one([for queue in aws_sqs_queue.nsse : queue.arn
                  if var.order_confirmed_topic.subscriptions[count.index] == queue.name])
}
