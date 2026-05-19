
output "security_group_id" {
  value       = aws_security_group.terraform_test_sg.id
  description = "Security Group ID"
}

// You can access module output variables using the following syntax:
// module.<MODULE_NAME>.<OUTPUT_NAME>
// module.infra_services_module.instance_arn