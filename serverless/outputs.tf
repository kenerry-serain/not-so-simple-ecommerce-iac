output "dlqueues_urls" {
  value = aws_sqs_queue.deadletter.*.id
}

output "queues_urls" {
  value = aws_sqs_queue.nsse.*.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.order_confirmed_topic.id
}