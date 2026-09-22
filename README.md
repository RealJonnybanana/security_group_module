# Alibaba Cloud Security Group Module

Creates an enterprise security group with internal traffic denied by default and explicit rules. The module blocks SSH port 22 and RDP port 3389 from being exposed to the entire IPv4 or IPv6 address space, including ranges that cover those ports and the `all` protocol.

## Requirements

- Terraform `>= 1.5.0`
- AliCloud Provider `>= 1.242.0, < 2.0.0`
- An existing VPC

## Usage

```hcl
module "security_group" {
  source = "./terraform-alicloud-security-group"

  security_group_name = "customer-app"
  vpc_id               = "vpc-example"
  rules = {
    https = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "443/443"
      cidr_ip     = "10.0.0.0/8"
    }
  }
}
```

See [`examples/minimal`](./examples/minimal) for a runnable example.

## Inputs

| Name | Required | Default | Description |
|---|---:|---|---|
| `security_group_name` | yes | — | Security-group name |
| `vpc_id` | yes | — | VPC containing the security group |
| `rules` | yes | — | Map of explicit rules |
| `description` | no | managed description | Description |
| `resource_group_id` | no | `null` | Resource group |
| `tags` | no | `{}` | Tags |

Each rule must specify exactly one of `cidr_ip`, `ipv6_cidr_ip`, `source_security_group_id`, or `prefix_list_id`. Supported protocols are tcp, udp, icmp, gre, and all.

## Outputs

`security_group_id`, `rule_ids`, and the audit-oriented `rule_summary`.

## Operations and Limitations

- The module fixes `security_group_type = enterprise` and `inner_access_policy = Drop`.
- Intra-group communication is denied by default. Required east-west traffic must be declared explicitly.
- VPC Flow Logs, alerts, and exception approval belong to the customer's governance stack.
- Before destruction, detach the group from consumers such as ECS instances, ENIs, and NLBs.
- Corresponding CIS v2.0.0 controls: 3.2, 3.3, 3.5, 4.3, and 4.4.

## Validation

```bash
terraform init -backend=false
terraform validate
terraform test
```
