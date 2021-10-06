output "VPC_ID" {
  description = "ID of the sample-vpc"
  value       = module.vpc.vpc_id
}

output "SAMPLE_SERVER_IP" {
  description = "Puplic IP address of  EC2 instance"
  value       = module.server.public_ip
}