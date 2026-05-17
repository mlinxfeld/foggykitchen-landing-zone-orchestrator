# OCI-Azure Interconnect Pattern

This directory contains the shared **multicloud OCI-Azure interconnect orchestration pattern** used by FoggyKitchen Landing Zone Orchestrator.

---

## 🎯 Purpose

The goal of this pattern is to compose a **private OCI-Azure connectivity foundation** using:

- Azure VNet and private workload placement
- Azure ExpressRoute and Virtual Network Gateway
- OCI VCN and private workload placement
- OCI DRG and FastConnect virtual circuit
- staged Azure gateway connection activation

This pattern is intended as a **reference orchestration layer**, not a finished productized interconnect abstraction.

---

## ✨ What The Pattern Builds

The pattern composes:

- one Azure Resource Group
- one Azure VNet with `private` and `gateway` subnets
- one Azure NSG baseline for the private subnet
- one Azure private VM
- one Azure ExpressRoute circuit
- one Azure Virtual Network Gateway
- one OCI VCN with a private subnet
- one OCI security list baseline
- one OCI private VM
- one OCI DRG
- one OCI FastConnect private virtual circuit
- one optional Azure Virtual Network Gateway connection

---

## 📂 Key Files

- [`main.tf`](main.tf)
- [`locals.tf`](locals.tf)
- [`variables.tf`](variables.tf)
- [`outputs.tf`](outputs.tf)
- [`versions.tf`](versions.tf)

The pattern is consumed by the thin example wrapper in:

- [`examples/multicloud/interconnect/oci_azure_interconnect/basic`](../../../../examples/multicloud/interconnect/oci_azure_interconnect/basic/README.md)

---

## 🧩 Input Model

The pattern expects:

- `payload_file`

That file should point to a YAML payload describing:

- `landing_zone`
- `azure`
- `oci`
- `interconnect`

The payload is normalized in [`locals.tf`](locals.tf) and then wired into a combination of FoggyKitchen modules and selected raw provider resources.

---

## 🌉 Transitional Interconnect Model

This pattern currently mixes:

- FoggyKitchen modules for the Azure and OCI foundational layers
- raw provider resources for interconnect edge components

That is intentional at this stage because there are no dedicated FoggyKitchen modules yet for:

- Azure ExpressRoute edge resources
- OCI FastConnect edge resources
- interconnect-specific DRG edge abstractions

---

## ⏳ Staged Azure Connection

`azurerm_virtual_network_gateway_connection` is controlled by:

- `interconnect.azure.connection.enabled`

Recommended flow:

1. start with `enabled: false`
2. apply the pattern to create Azure and OCI interconnect foundations
3. wait until FastConnect and ExpressRoute are operationally ready
4. change the flag to `true`
5. apply again to create the Azure gateway connection

This avoids trying to create the final Azure connection before the OCI side is actually ready.

---

## 📤 Outputs

The pattern exposes outputs for:

- Azure resource group and VNet identifiers
- Azure subnet identifiers
- Azure VM private IP
- Azure ExpressRoute circuit ID and service key
- Azure gateway connection ID
- OCI VCN and subnet identifiers
- OCI VM private IP
- OCI DRG ID
- OCI virtual circuit ID

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../../../../LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
