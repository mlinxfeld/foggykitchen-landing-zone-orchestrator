# Architecture

## Core Idea

The orchestrator treats YAML as an architecture contract rather than a raw resource manifest.

The payload expresses:

- topology
- access model
- routing intent
- security intent
- feature switches
- workload placement

Terraform/OpenTofu then maps that intent to statically declared FoggyKitchen module calls.

## MVP Pattern

The implemented MVP is an Azure hub-and-spoke landing zone:

- one resource group
- one hub VNet
- two spoke VNets
- bidirectional VNet peering
- subnet-level NSGs
- route table attachments
- NAT Gateway for selected private subnets
- Azure Bastion for operator access
- Private DNS zones linked to all VNets
- one private VM workload
- one internal load balancer

## Why Thin Composition

This repository intentionally does not reimplement networking, compute, or DNS internals. Those concerns stay inside the dedicated FoggyKitchen modules. The orchestrator only normalizes payload input, resolves references, and wires modules together.

## Azure MVP Boundaries

Included:

- VNet and subnet creation
- peering
- routing scaffolding
- NSG baselines
- outbound egress identity via NAT
- bastion access
- private DNS
- compute placement
- internal traffic entry via ILB

Not included in MVP:

- Azure Firewall transit
- private endpoints
- storage and platform services
- AKS
- RBAC and governance overlays
- CI/CD and policy-as-code
