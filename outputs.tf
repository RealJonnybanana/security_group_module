output "security_group_id" {
  description = "Security group ID."
  value       = alicloud_security_group.this.id
}

output "rule_ids" {
  description = "Map of rule keys to Terraform rule IDs."
  value       = { for key, rule in alicloud_security_group_rule.this : key => rule.id }
}

output "rule_summary" {
  description = "Rule summary consumed by audit and change-alerting systems."
  value = {
    for key, rule in var.rules : key => {
      type         = rule.type
      ip_protocol  = rule.ip_protocol
      port_range   = rule.port_range
      policy       = rule.policy
      priority     = rule.priority
      cidr_ip      = try(rule.cidr_ip, null)
      ipv6_cidr_ip = try(rule.ipv6_cidr_ip, null)
    }
  }
}
