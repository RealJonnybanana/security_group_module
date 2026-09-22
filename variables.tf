variable "security_group_name" {
  description = "Security group name."
  type        = string
}

variable "description" {
  description = "Security group description."
  type        = string
  default     = "Managed enterprise security group"
}

variable "vpc_id" {
  description = "ID of the VPC containing the security group."
  type        = string
}

variable "resource_group_id" {
  description = "Resource group ID."
  type        = string
  default     = null
}

variable "tags" {
  description = "Standard tags."
  type        = map(string)
  default     = {}
}

variable "rules" {
  description = "Fine-grained security group rules; each rule must specify exactly one source or destination."
  type = map(object({
    type                     = string
    ip_protocol              = string
    port_range               = string
    policy                   = optional(string, "accept")
    priority                 = optional(number, 1)
    nic_type                 = optional(string, "intranet")
    cidr_ip                  = optional(string)
    ipv6_cidr_ip             = optional(string)
    source_security_group_id = optional(string)
    prefix_list_id           = optional(string)
    description              = optional(string)
  }))

  validation {
    condition = alltrue([
      for rule in values(var.rules) : contains(["ingress", "egress"], rule.type)
    ])
    error_message = "rules.type must be ingress or egress."
  }

  validation {
    condition = alltrue([
      for rule in values(var.rules) : contains(["tcp", "udp", "icmp", "gre", "all"], rule.ip_protocol)
    ])
    error_message = "rules.ip_protocol must be tcp, udp, icmp, gre, or all."
  }

  validation {
    condition = alltrue([
      for rule in values(var.rules) : length(compact([
        try(rule.cidr_ip, null),
        try(rule.ipv6_cidr_ip, null),
        try(rule.source_security_group_id, null),
        try(rule.prefix_list_id, null)
      ])) == 1
    ])
    error_message = "Each rule must specify exactly one of cidr_ip, ipv6_cidr_ip, source_security_group_id, or prefix_list_id."
  }

  validation {
    condition = alltrue([
      for rule in values(var.rules) : can(regex("^(-1/-1|[0-9]+/[0-9]+)$", rule.port_range))
    ])
    error_message = "port_range must use the start/end format, for example 443/443 or -1/-1."
  }
}
