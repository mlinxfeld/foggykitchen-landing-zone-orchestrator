# OCI DRG Hub-and-Spoke Landing Zone

This example provides one payload for the shared **OCI DRG hub-and-spoke orchestrator pattern**.

---

## 🎯 Purpose

The goal of this example is to show a **DRG-centric OCI landing zone pattern** for:

- strategic inter-VCN connectivity
- private-first workload placement
- explicit routing through DRG attachments
- clean separation of application and data networks

---

## ✨ What the example does

This example composes:

- one hub VCN
- one app spoke VCN
- one data spoke VCN
- one DRG
- DRG attachments for all VCNs
- per-VCN route tables that send inter-VCN traffic through the DRG
- private subnets and security lists
- one private application instance
- one private data instance
- one private load balancer in the app VCN

---

## 📂 Pattern And Payload

The shared pattern lives in:

- [`patterns/oci/drg_hub_spoke`](../../../../../patterns/oci/drg_hub_spoke)

This example contributes:

- [`landing-zone.yaml`](landing-zone.yaml)
- a thin wrapper [`main.tf`](main.tf)
- provider configuration

---

## 🚀 Deployment

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

---

## 📤 Expected Outputs

- DRG ID
- VCN IDs
- subnet IDs
- private IPs of instances
- private IPs of the load balancer

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

- This example focuses on DRG-centric connectivity, not enterprise governance.
- It uses VCN security lists, not a broader OCI security framework.
- LPG remains a separate planned example.

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../../../../../LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
