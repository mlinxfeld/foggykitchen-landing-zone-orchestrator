# OCI-Azure Interconnect Landing Zone

This example provides one payload for the shared **OCI-Azure Interconnect orchestrator pattern** inspired by the FoggyKitchen multicloud course.

---

## 🎯 Purpose

The goal of this example is to show a **private multicloud connectivity pattern** between Azure and OCI using:

- Azure ExpressRoute
- OCI FastConnect
- OCI DRG
- private workloads on both sides
- explicit edge resources and route flow

---

## ✨ What the example does

This example composes:

- one Azure resource group
- one Azure VNet with private and gateway subnets
- one Azure VM in a private subnet
- one Azure ExpressRoute circuit
- one Azure Virtual Network Gateway
- one OCI VCN with a private subnet
- one OCI VM in a private subnet
- one OCI DRG
- one OCI FastConnect private virtual circuit
- one Azure-to-OCI private interconnect path

---

## 📂 Pattern And Payload

The shared pattern lives in:

- [`patterns/multicloud/oci_azure_interconnect`](../../../../../patterns/multicloud/oci_azure_interconnect)

This example contributes:

- [`landing-zone.yaml`](landing-zone.yaml)
- a thin wrapper [`main.tf`](main.tf)
- provider configuration

Unlike the other patterns, the interconnect edge resources are currently implemented directly in HCL because dedicated FoggyKitchen modules for ExpressRoute and FastConnect are not yet part of the module catalog.

---

## 🚀 Deployment

This example is intended to be deployed in **two stages** because `azurerm_virtual_network_gateway_connection` will succeed only after the OCI FastConnect side is fully provisioned and operational.

OpenTofu:

```bash
tofu init
tofu plan \
  -var="user_ocid=ocid1.user.oc1..example" \
  -var="fingerprint=aa:bb:cc:dd" \
  -var="private_key_path=~/.oci/oci_api_key.pem" \
  -var="admin_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
tofu apply \
  -var="user_ocid=ocid1.user.oc1..example" \
  -var="fingerprint=aa:bb:cc:dd" \
  -var="private_key_path=~/.oci/oci_api_key.pem" \
  -var="admin_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
```

Terraform:

```bash
terraform init
terraform plan \
  -var="user_ocid=ocid1.user.oc1..example" \
  -var="fingerprint=aa:bb:cc:dd" \
  -var="private_key_path=~/.oci/oci_api_key.pem" \
  -var="admin_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
terraform apply \
  -var="user_ocid=ocid1.user.oc1..example" \
  -var="fingerprint=aa:bb:cc:dd" \
  -var="private_key_path=~/.oci/oci_api_key.pem" \
  -var="admin_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
```

Stage 1:

- keep `interconnect.azure.connection.enabled: false` in [`landing-zone.yaml`](landing-zone.yaml)
- run `apply` to create Azure and OCI interconnect foundations

Stage 2:

- after FastConnect and ExpressRoute are fully ready, change `interconnect.azure.connection.enabled` to `true`
- run `apply` again to create `azurerm_virtual_network_gateway_connection`

---

## 📤 Expected Outputs

- Azure VNet and subnet IDs
- Azure private VM IP
- Azure ExpressRoute circuit ID
- Azure Virtual Network Gateway connection ID
- OCI VCN and subnet IDs
- OCI private VM IP
- OCI DRG ID
- OCI virtual circuit ID

---

## 🧹 Cleanup

```bash
tofu destroy \
  -var="user_ocid=ocid1.user.oc1..example" \
  -var="fingerprint=aa:bb:cc:dd" \
  -var="private_key_path=~/.oci/oci_api_key.pem" \
  -var="admin_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
```

---

## ⚠️ Known Limitations

- This is a reference implementation, not a production interconnect product.
- Partner-side provisioning constraints and commercial prerequisites may apply.
- ExpressRoute and FastConnect edge resources are not yet abstracted into dedicated FoggyKitchen modules.

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../../../../../LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
