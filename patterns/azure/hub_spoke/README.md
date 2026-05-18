# Azure Hub-And-Spoke Pattern

This directory contains the shared **Azure hub-and-spoke landing zone pattern** used by FoggyKitchen Landing Zone Orchestrator.

---

## 🎯 Purpose

The goal of this pattern is to provide a reusable Azure networking foundation with:

- one hub VNet
- multiple spoke VNets
- peering
- route table attachment
- NSG baselines
- NAT, Bastion, and Private DNS as optional capabilities
- private VM placement
- internal load balancer support

---

## ✨ What The Pattern Builds

The pattern composes:

- one Azure Resource Group
- one hub VNet
- spoke VNets for application and data tiers
- hub-to-spoke and spoke-to-hub peering
- subnet-level NSGs
- optional route tables
- optional NAT Gateway egress
- optional Azure Bastion
- optional Private DNS zones and VNet links
- private VM workloads
- optional internal load balancer

---

## 📂 Key Files

- [`main.tf`](main.tf)
- [`locals.tf`](locals.tf)
- [`variables.tf`](variables.tf)
- [`outputs.tf`](outputs.tf)
- [`versions.tf`](versions.tf)

This pattern is consumed by:

- [`examples/azure/networking/hub_spoke/basic`](../../../../examples/azure/networking/hub_spoke/basic/README.md)

---

## 🧩 Input Model

The pattern expects:

- `payload_file`

The payload is expected to describe sections such as:

- `landing_zone`
- `cloud`
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

---

## ⚠️ Current Notes

- the internal load balancer uses `terraform-az-fk-loadbalancer` with a private frontend
- this pattern acts as the shared base for the Azure `private_endpoint` pattern

---

## 📤 Outputs

The pattern exposes outputs for:

- resource group name
- hub and spoke VNet IDs
- subnet IDs
- NAT public IP
- Bastion name
- Private DNS zone IDs
- VM private IPs
- internal load balancer private IP

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../../../../LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
