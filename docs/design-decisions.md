# Design Decisions

## Static Module Sources

All FoggyKitchen modules are declared statically in HCL. This keeps the implementation understandable, reviewable, and aligned with Terraform/OpenTofu module resolution rules.

## Direct Resource Group

The example creates the Azure resource group directly with `azurerm_resource_group` because the brief explicitly allows it and there is no separate FoggyKitchen resource group module in scope.

## Direct Internal Load Balancer

The current `terraform-az-fk-loadbalancer` module is public-frontend focused. The MVP requires an internal load balancer, so the example implements ILB resources directly with AzureRM while still using the FoggyKitchen compute module for backend attachment.

## Routing in the MVP

The routing module is included in the landing zone core. In the current payload, route tables are attached explicitly and can inject next-hop routes when a firewall or transit appliance is enabled later. This keeps routing visible in the architecture, even when the first MVP does not yet deploy Azure Firewall.

## Single Example First

Only one example is fully implemented. This keeps the repository understandable and aligned with the brief's requirement to start small.
