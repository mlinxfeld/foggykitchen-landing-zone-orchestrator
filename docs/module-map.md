# Module Map

This document maps the current repository patterns to the FoggyKitchen modules they compose.

---

## 🎯 Purpose

The goal of this map is to show how the repository turns individual modules into **coherent architecture patterns**.

---

## ☁️ Azure Core Modules

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
| `terraform-az-fk-loadbalancer` | Public and private traffic entry contract |
| `terraform-az-fk-storage` | Storage service layer |
| `terraform-az-fk-private-endpoint` | Private service exposure |
| `terraform-az-fk-firewall` | Central inspection and transit boundary |

---

## 🧩 Azure Pattern Usage

### `patterns/azure/hub_spoke`

Uses:

- `terraform-az-fk-vnet`
- `terraform-az-fk-vnet-peering`
- `terraform-az-fk-nsg`
- `terraform-az-fk-public-ip`
- `terraform-az-fk-natgw`
- `terraform-az-fk-bastion`
- `terraform-az-fk-private-dns`
- `terraform-az-fk-compute`
- `terraform-az-fk-loadbalancer`

Optional by payload:

- `terraform-az-fk-routing`

### `patterns/azure/private_endpoint`

Uses:

- everything from `hub_spoke` indirectly
- `terraform-az-fk-storage`
- `terraform-az-fk-private-endpoint`
- optionally `terraform-az-fk-compute` a second time for `compute_storage_mounts`

Why the extra compute call:

- generic `hub_spoke` compute is storage-agnostic
- a consumer VM that mounts Azure Files needs Storage Account outputs
- the private endpoint pattern therefore creates that VM after Storage Account provisioning when `compute_storage_mounts` is enabled

### `patterns/azure/firewall_transit`

Uses:

- `terraform-az-fk-vnet`
- `terraform-az-fk-vnet-peering`
- `terraform-az-fk-routing`
- `terraform-az-fk-public-ip`
- `terraform-az-fk-firewall`
- `terraform-az-fk-compute`

---

## ☁️ OCI Core Modules

| Module | Role in the landing zone |
| --- | --- |
| `terraform-oci-fk-vcn` | Network boundary |
| `terraform-oci-fk-lpg` | Same-region local peering |
| `terraform-oci-fk-drg` | Strategic routing and transit layer |
| `terraform-oci-fk-compute` | Workload layer |
| `terraform-oci-fk-loadbalancer` | Traffic entry and distribution contract |

---

## 🧩 OCI Pattern Usage

### `patterns/oci/drg_cross_region`

Uses:

- `terraform-oci-fk-vcn`
- `terraform-oci-fk-drg`

Why this pattern is narrower:

- it focuses on OCI-native cross-region DRG and RPC composition
- it intentionally leaves compute and load balancer concerns out of scope
- it maps more directly to the `terraform-oci-fk-drg` remote peering reference scenario

### `patterns/oci/lpg_local_peering`

Uses:

- `terraform-oci-fk-vcn`
- `terraform-oci-fk-lpg`
- `terraform-oci-fk-compute`
- `terraform-oci-fk-loadbalancer`

---

## ⚠️ Current Gaps

The current module map does not yet include dedicated FoggyKitchen modules for:

- Azure ExpressRoute edge resources
- OCI FastConnect edge resources
- OCI interconnect-specific DRG edge abstractions
- advanced multicloud blueprint composition in the private `foggykitchen-landing-zone-blueprint` repository

Those are natural future expansion points for the module catalog and premium blueprint layer.

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
