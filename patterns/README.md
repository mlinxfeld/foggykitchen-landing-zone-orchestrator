# Patterns

This directory contains the **shared HCL orchestration patterns** used by FoggyKitchen Landing Zone Orchestrator.

---

## 🎯 Purpose

Patterns are the reusable implementation layer of the repository.

They are responsible for:

- normalizing YAML payload input
- resolving logical references
- composing FoggyKitchen modules
- exposing a stable pattern interface to examples

Examples under `examples/` should stay thin and delegate architecture logic to the shared patterns in this directory.

---

## 📂 Pattern Families

### Azure

- [README](azure/README.md)
- [hub_spoke](azure/hub_spoke)
- [private_endpoint](azure/private_endpoint)
- [firewall_transit](azure/firewall_transit)

### OCI

- [README](oci/README.md)
- [drg_hub_spoke](oci/drg_hub_spoke)
- [lpg_local_peering](oci/lpg_local_peering)

### Multicloud

- [README](multicloud/README.md)
- [oci_azure_interconnect](multicloud/oci_azure_interconnect)

---

## 🧭 How To Read This Directory

Recommended order:

1. start with [docs/architecture.md](../docs/architecture.md)
2. review [docs/payload-contract.md](../docs/payload-contract.md)
3. inspect the relevant pattern directory
4. compare it with one of the thin example wrappers under `examples/`

---

## ⚠️ Current Notes

- `azure/hub_spoke` is the shared base for the Azure networking-oriented patterns
- `azure/private_endpoint` extends the shared Azure networking foundation
- `multicloud/oci_azure_interconnect` currently mixes FoggyKitchen modules with raw provider resources for the interconnect edge layer

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
