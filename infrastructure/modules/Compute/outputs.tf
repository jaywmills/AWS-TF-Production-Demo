output "internal_webserver" {
  value = aws_instance.Internal_Apache_Webserver.id
}

output "internal_admin_workstation" {
  value = aws_instance.Windows_Admin_Workstation.id
}