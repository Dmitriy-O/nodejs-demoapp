output "notification_topic_arn" {
  value = try(aws_sns_topic.scaling_events[0].arn, null)
}
