# OCI LPG Local Peering Landing Zone

This example provides one payload for the shared **OCI local peering orchestrator pattern**.

---

## 🎯 Purpose

The goal of this example is to show a **same-region OCI local peering pattern** for:

- app-to-data VCN connectivity
- private-first workload placement
- explicit LPG-based routing
- simple two-VCN architecture composition

---

## ✨ What the example does

This example composes:

- one app VCN
- one data VCN
- one LPG per VCN
- local peering between both VCNs
- private subnets and security lists
- one private application instance
- one private data instance
- one private load balancer in the app VCN

---

## 📂 Pattern And Payload

The shared pattern lives in:

- [`patterns/oci/lpg_local_peering`](../../../../../patterns/oci/lpg_local_peering)

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

---

## 📤 Expected Outputs

- LPG IDs
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

- This example focuses on same-region LPG connectivity only.
- DRG-based transit remains covered by example `03`.

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../../../../../LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
