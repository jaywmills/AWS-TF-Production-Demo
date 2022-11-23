output "public_bastion" {
  value = aws_security_group.public_bastion.id
}

output "public_rdp" {
  value = aws_security_group.public_rdp.id
}

output "private_rdp" {
  value = aws_security_group.private_rdp.id
}

output "internal_alb" {
  value = aws_security_group.internal_alb.id
}

output "internal_webserver" {
  value = aws_security_group.internal_webserver.id
}

output "private_database_sg" {
  value = aws_security_group.private_database_sg.id
}