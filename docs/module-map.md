# Module Map

## Azure Core

| Module | Role in the landing zone |
| --- | --- |
| `terraform-az-fk-vnet` | Network boundary |
| `terraform-az-fk-vnet-peering` | Connectivity contract |
| `terraform-az-fk-routing` | Traffic control and UDR layer |
| `terraform-az-fk-nsg` | Security boundary |
| `terraform-az-fk-public-ip` | Public identity for platform egress |
| `terraform-az-fk-natgw` | Outbound identity and egress boundary |
| `terraform-az-fk-bastion` | Secure operator access |
| `terraform-az-fk-private-dns` | Private name resolution layer |
| `terraform-az-fk-compute` | Workload layer |
| `terraform-az-fk-loadbalancer` | Public traffic entry contract |

## Azure MVP Implementation Notes

The MVP directly uses all Azure core modules except `terraform-az-fk-loadbalancer`. That module remains part of the architecture map, but the current example needs an internal load balancer and therefore uses `azurerm_lb` resources directly.

The Azure private endpoint example additionally uses:

- `terraform-az-fk-storage`
- `terraform-az-fk-private-endpoint`

## OCI Core

- `terraform-oci-fk-vcn`
- `terraform-oci-fk-lpg`
- `terraform-oci-fk-drg`
- `terraform-oci-fk-compute`
- `terraform-oci-fk-loadbalancer`
