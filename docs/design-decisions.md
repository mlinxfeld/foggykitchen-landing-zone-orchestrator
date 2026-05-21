# Design Decisions

This document summarizes the key **engineering decisions and tradeoffs** made in the repository.

---

## 🎯 Purpose

The goal of these decisions is to keep the orchestrator:

- explicit
- composable
- architecture-first
- easy to review and extend

---

## 🧠 Static Module Sources

All FoggyKitchen modules are declared **statically in HCL**.

Why:

- keeps the implementation reviewable
- matches Terraform / OpenTofu module resolution rules
- avoids dangerous or opaque dynamic source loading

This means the YAML payload can control intent, but **not** module source locations.

---

## 🧩 Shared Patterns + Thin Examples

The repository uses:

- `patterns/` for shared orchestration logic
- `examples/` for payload variants and wrapper entry points

Why:

- avoids copying the same HCL into every example
- makes payload comparison easy
- scales better than flat numbered examples

---

## 📂 Domain-Oriented Example Layout

Examples are grouped by:

- cloud
- domain
- pattern
- variant

Why:

- avoids a flat `01`, `02`, `03`, ... sprawl
- remains searchable as the catalog grows
- mirrors the mental model already present in `patterns/`

---

## 🏗️ Direct Resource Group in Azure Patterns

Azure patterns create the Resource Group directly with `azurerm_resource_group`.

Why:

- the brief explicitly allowed it
- there is no dedicated FoggyKitchen Resource Group module in scope
- adding indirection here would not improve the architecture

---

## 🌐 Shared Internal Load Balancer in Azure

Azure internal load balancer scenarios now use:

- `terraform-az-fk-loadbalancer`

Why:

- keeps Azure load balancer behavior inside a dedicated reusable module
- preserves consistency between public and private frontend patterns
- removes raw internal load balancer resources from the orchestrator

The module was extended in a backward-compatible way so existing public load balancer consumers do not require refactoring.

---

## 🔥 Dedicated Firewall Transit Pattern

Azure Firewall was not folded into the baseline `hub_spoke` pattern.

Instead, it was separated into:

- `patterns/azure/firewall_transit`

Why:

- it represents a distinct topology and operational model
- it changes routing intent materially
- it deserves its own payload contract and example lineage

---

## 🔁 Routing As Architecture

Routing is treated as a first-class concern in the patterns.

Why:

- without routing, many examples would only be network skeletons
- DRG, LPG, and firewall transit patterns are primarily about route intent

This is why routing is visible in payload structure and not hidden behind too much abstraction.

---

## 📦 Runner IP Allowlist For Azure Files Provisioning

The `azure/private_endpoint` storage example accepts:

- `provisioner_public_ip`

Why:

- Azure Files share creation is a Storage data-plane operation
- the orchestrator keeps the Storage Account behind network rules with `default_action = Deny`
- the OpenTofu runner still needs a narrow way to create the file share during provisioning

This is treated as an operational workaround, not as the intended workload path.
The runtime consumer VM continues to access Azure Files through:

- Private DNS
- Private Endpoint
- routed hub-and-spoke transit via the router VM

This is why the public IP is passed as a wrapper variable and not embedded into `landing-zone.yaml` as architecture intent.

---

## 🔒 Public Repo Boundary

The public orchestrator is intentionally optimized for:

- Azure single-cloud reference patterns
- OCI single-cloud reference patterns
- educational and reviewable composition

Advanced multicloud implementations are treated as premium blueprint material and can be maintained separately in the private:

- `foggykitchen-landing-zone-blueprint`

repository.

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
