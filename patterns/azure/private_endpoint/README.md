# Azure Private Endpoint Pattern

This directory contains the shared **Azure private endpoint landing zone pattern** used by FoggyKitchen Landing Zone Orchestrator.

---

## 🎯 Purpose

The goal of this pattern is to extend the shared Azure hub-and-spoke foundation with:

- Storage Account deployment
- private access only
- Private Endpoint resources
- Private DNS integration

---

## ✨ What The Pattern Builds

The pattern composes:

- the full `hub_spoke` Azure foundation
- one Azure Storage Account
- one or more Private Endpoints
- Private DNS zone bindings for private service resolution

---

## 📂 Key Files

- [`main.tf`](main.tf)
- [`locals.tf`](locals.tf)
- [`variables.tf`](variables.tf)
- [`outputs.tf`](outputs.tf)
- [`versions.tf`](versions.tf)

This pattern is consumed by:

- [`examples/azure/networking/private_endpoint/storage_private_link`](../../../../examples/azure/networking/private_endpoint/storage_private_link/README.md)

---

## 🧩 Input Model

The pattern expects:

- `payload_file`

The payload is expected to include the baseline Azure networking contract plus:

- `storage`
- `private_endpoints`

The payload is normalized in [`locals.tf`](locals.tf), where logical subnet references are resolved through the shared `hub_spoke` outputs.

---

## ⚠️ Current Notes

- this pattern reuses `hub_spoke` rather than duplicating the Azure networking foundation
- the current example focuses on Storage private access

---

## 📤 Outputs

The pattern exposes outputs for:

- all inherited `hub_spoke` foundation outputs
- Storage Account ID and name
- blob and file endpoints
- Private Endpoint IDs
- Private Endpoint private IPs

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../../../../LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
