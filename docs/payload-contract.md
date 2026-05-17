# Payload Contract

## Intent

The payload contract is architecture-first. It should describe what pattern the user wants, not where every low-level Azure argument comes from.

## Top-Level Sections

- `landing_zone`
- `cloud`
- `architecture`
- `features`
- `networking`
- `peering`
- `routing`
- `security`
- `nat_gateway`
- `bastion`
- `private_dns`
- `compute`
- `load_balancer`

## Reference Patterns

String references in the payload use dotted notation:

- `hub.bastion`
- `hub.shared`
- `app.frontend`
- `app.backend`
- `data.database`

These references are resolved in `locals.tf` to concrete subnet IDs and subnet CIDRs.

## Rules

1. Module sources are never configurable from YAML.
2. Feature flags may enable or disable entire composed capabilities.
3. Workload placement is expressed through references such as `subnet_ref`.
4. Routing intent is allowed to be higher level than final Azure route entries.
5. Payload readers should prefer stable logical names over Azure resource IDs.

## MVP Notes

For the Azure MVP:

- routing tables are always explicit when `routing.enabled = true`
- firewall next-hop routes are only injected when `routing.firewall_next_hop.enabled = true`
- private DNS zones are linked to hub and spoke VNets
- load balancer backends are selected from `compute.instances`
