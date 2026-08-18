output "web_instance_id" { value = aws_instance.webserver.id }
output "web_sg_id" { value = aws_security_group.web_sg.id }
