locals {
  public_admin_rules = {
    for key, rule in var.rules : key => rule
    if rule.type == "ingress"
    && try(rule.policy, "accept") == "accept"
    && contains(["0.0.0.0/0", "::/0"], coalesce(try(rule.cidr_ip, null), try(rule.ipv6_cidr_ip, null), "not-a-public-cidr"))
    && (
      rule.ip_protocol == "all"
      || rule.port_range == "-1/-1"
      || (
        contains(["tcp", "udp"], rule.ip_protocol)
        && (
          (tonumber(split("/", rule.port_range)[0]) <= 22 && tonumber(split("/", rule.port_range)[1]) >= 22)
          || (tonumber(split("/", rule.port_range)[0]) <= 3389 && tonumber(split("/", rule.port_range)[1]) >= 3389)
        )
      )
    )
  }
}

resource "alicloud_security_group" "this" {
  security_group_name = var.security_group_name
  description         = var.description
  vpc_id              = var.vpc_id
  resource_group_id   = var.resource_group_id
  security_group_type = var.security_group_type
  inner_access_policy = var.security_group_type == "enterprise" ? "Drop" : null
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags["CreatedOnDate"]
    ]

    precondition {
      condition     = length(local.public_admin_rules) == 0
      error_message = "Opening SSH (22) or RDP (3389) from 0.0.0.0/0 or ::/0 is prohibited, including through port ranges or all."
    }
  }
}

resource "alicloud_security_group_rule" "this" {
  for_each = var.rules

  security_group_id        = alicloud_security_group.this.id
  type                     = each.value.type
  ip_protocol              = each.value.ip_protocol
  port_range               = each.value.port_range
  policy                   = each.value.policy
  priority                 = each.value.priority
  nic_type                 = each.value.nic_type
  cidr_ip                  = try(each.value.cidr_ip, null)
  ipv6_cidr_ip             = try(each.value.ipv6_cidr_ip, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
  prefix_list_id           = try(each.value.prefix_list_id, null)
  description              = try(each.value.description, null)
}
