# Azure Hub-and-Spoke Landing Zone

This example provides one payload for the shared **Azure hub-and-spoke orchestrator pattern**.

---

## 🎯 Purpose

The goal of this example is to show a **clean, reusable Azure landing zone composition** built from FoggyKitchen modules:

- hub-and-spoke networking
- centralized routing structure
- subnet-level security boundaries
- private-first compute
- NAT-based outbound access
- Bastion-based operator access
- internal load balancing

---

## ✨ What the example does

This example composes:

- one resource group
- one hub VNet
- one app spoke VNet
- one data spoke VNet
- hub-to-spoke peering
- route tables attached to spoke subnets
- subnet-level NSGs
- NAT Gateway on selected private subnets
- Azure Bastion
- Private DNS zones linked to all VNets
- one private Linux VM
- one internal load balancer

---

## 📂 Pattern And Payload

The shared pattern lives in:

- [`patterns/azure/hub_spoke`](../../../../../patterns/azure/hub_spoke)

This example contributes:

- [`landing-zone.yaml`](landing-zone.yaml)
- a thin wrapper [`main.tf`](main.tf)
- provider configuration

The wrapper passes the payload into the shared HCL pattern, so the pattern code stays common and the payload carries the architecture intent.

---

## 🧩 Module Map

- `terraform-az-fk-vnet` for hub and spoke VNets
- `terraform-az-fk-vnet-peering` for connectivity
- `terraform-az-fk-routing` for route table orchestration
- `terraform-az-fk-nsg` for subnet-level security boundaries
- `terraform-az-fk-public-ip` for NAT public identity
- `terraform-az-fk-natgw` for outbound egress
- `terraform-az-fk-bastion` for secure operator access
- `terraform-az-fk-private-dns` for private DNS zones and VNet links
- `terraform-az-fk-compute` for the application VM
- `terraform-az-fk-loadbalancer` for the internal application load balancer

---

## 🚀 Deployment

OpenTofu:

```bash
tofu init
tofu plan
tofu apply
```

Terraform:

```bash
terraform init
terraform plan
terraform apply
```

If you want to inject your own public key instead of generating one automatically, pass:

```bash
tofu apply -var="admin_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
```

---

## 📤 Expected Outputs

- resource group name
- hub and spoke VNet IDs
- subnet IDs
- NAT Gateway public IP
- Bastion name
- app VM private IP
- internal load balancer private IP
- generated admin SSH private key PEM when `admin_ssh_public_key` is left empty

---

## 🧹 Cleanup

OpenTofu:

```bash
tofu destroy
```

Terraform:

```bash
terraform destroy
```

---

## ⚠️ Known Limitations

- Route tables are explicit, but transit next-hop routes are only injected when a future firewall or NVA next hop is enabled.
- Azure Firewall is intentionally out of MVP scope.
- Private Endpoint integration is a planned next step.

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../../../../../LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
