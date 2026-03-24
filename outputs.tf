output "ec2_public_ip" {
  description = "The public IP of the EpicBook web server"
  value       = aws_instance.web_vm.public_ip
}

output "rds_endpoint" {
  description = "The internal endpoint of the RDS database"
  value       = aws_db_instance.epicbook_db.address
}
