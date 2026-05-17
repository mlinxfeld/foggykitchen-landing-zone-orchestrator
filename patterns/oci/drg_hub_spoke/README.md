# OCI DRG Hub-And-Spoke Pattern

This directory contains the shared **OCI DRG hub-and-spoke landing zone pattern** used by FoggyKitchen Landing Zone Orchestrator.

---

## 🎯 Purpose

The goal of this pattern is to provide a reusable OCI network architecture with:

- multiple VCNs
- DRG-based transit
- explicit route intent
- private compute placement
- private load balancing

---

## ✨ What The Pattern Builds

The pattern composes:

- multiple OCI VCNs
- DRG
- DRG attachments
- DRG route tables
- private subnets and security lists
- private compute instances
- optional private load balancer

---

## 📂 Key Files

- [`main.tf`](main.tf)
- [`locals.tf`](locals.tf)
- [`variables.tf`](variables.tf)
- [`outputs.tf`](outputs.tf)
- [`versions.tf`](versions.tf)

This pattern is consumed by:

- [`examples/oci/networking/drg_hub_spoke/basic`](../../../../examples/oci/networking/drg_hub_spoke/basic/README.md)

---

## 🧩 Input Model

The pattern expects:

- `payload_file`

The payload is expected to include sections such as:

- `landing_zone`
- `cloud`
- `networking`
- `connectivity`
- `compute`
- `load_balancer`

The payload is normalized in [`locals.tf`](locals.tf), where VCN layout, DRG route intent, compute placement, and backend membership are resolved.

---

## 📤 Outputs

The pattern exposes outputs for:

- compartment OCID
- DRG ID and attachment IDs
- VCN IDs
- subnet IDs
- instance private and public IPs
- load balancer ID
- load balancer private IPs

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../../../../LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
