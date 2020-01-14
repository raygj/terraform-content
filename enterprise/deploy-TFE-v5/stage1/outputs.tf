output "vpc_id" {
  value       = module.new_vpc.vpc_id
  description = "The id of the created VPC"
}

output "subnet_tags" {
  value       = local.tags
  description = "The tags associated with the subnets created"
}

output "route53" {
  value = {
    zone_id      = element(coalescelist(aws_route53_zone.new.*.zone_id, [""]), 0)
    name_servers = coalescelist(aws_route53_zone.new.*.name_servers, [""])
    domain_name  = var.domain_name
  }
}

output "kms_id" {
  value = aws_kms_key.s3.key_id
}

