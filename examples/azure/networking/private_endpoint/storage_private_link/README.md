# Azure Private Endpoint Landing Zone

This example provides one payload for the shared **Azure private endpoint orchestrator pattern**.

---

## 🎯 Purpose

The goal of this example is to show how the shared Azure landing zone can be extended with:

- private-first storage
- private endpoint exposure
- private DNS integration
- workload subnet allow-listing for service access

---

## ✨ What the example does

This example extends the shared Azure hub-and-spoke pattern with:

- a private-first storage account
- private DNS zones for storage private link
- private endpoints for `blob` and `file`
- private endpoint placement in the data spoke
- optional workload subnet allow-listing for storage network rules

---

## 📂 Pattern And Payload

The shared pattern lives in:

- [`patterns/azure/private_endpoint`](../../../../../patterns/azure/private_endpoint)

This example contributes:

- [`landing-zone.yaml`](landing-zone.yaml)
- a thin wrapper [`main.tf`](main.tf)
- provider configuration

The pattern reuses the common hub-spoke orchestrator and layers storage plus private endpoints on top.

---

## 🚀 Deployment

OpenTofu:

```bash
tofu init
tofu plan -var="admin_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
tofu apply -var="admin_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
```

Terraform:

```bash
terraform init
terraform plan -var="admin_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
terraform apply -var="admin_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
```

---

## 📤 Expected Outputs

- hub and spoke VNet IDs
- storage account name and ID
- private endpoint IDs
- private endpoint private IPs
- private DNS zone IDs

---

## 🧹 Cleanup

```bash
tofu destroy -var="admin_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
```

---

## ⚠️ Known Limitations

- The example focuses on Storage private endpoints first.
- It does not yet add Key Vault, SQL, or ACR endpoint variants.
- It inherits the current hub-spoke pattern limitations from example `01`.

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../../../../../LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
