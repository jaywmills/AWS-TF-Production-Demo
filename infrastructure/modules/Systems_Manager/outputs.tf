output "content" {
  value = data.aws_ssm_document.windows_security_updates.content
}

output "win_ssm_profile" {
  value = aws_iam_instance_profile.win_iam_profile.id
}

output "al2_ssm_profile" {
  value = aws_iam_instance_profile.al2_iam_profile.id
}