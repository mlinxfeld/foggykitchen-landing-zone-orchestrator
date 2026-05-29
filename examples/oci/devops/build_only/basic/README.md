# OCI DevOps Build-Only Basic Example

This example is a thin wrapper around the shared **OCI DevOps build-only** pattern.

It demonstrates a minimal CI flow made of:

- one DevOps project
- one mirrored GitHub repository
- one OCIR repository
- one Docker deploy artifact
- one build pipeline with `BUILD` and `DELIVER_ARTIFACT` stages

## Files

- `landing-zone.yaml`: payload describing the build-only pattern
- `main.tf`: thin wrapper around the shared pattern
- `providers.tf`: OCI provider configuration
- `variables.tf`: provider inputs
- `outputs.tf`: useful outputs
- `terraform.tfvars.example`: example provider values

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
tofu init
tofu plan
```

## Notes

- `devops.github.pat_secret_ocid` must point to an OCI Vault secret containing the GitHub personal access token
- this public pattern intentionally stops before OKE deployment
- a follow-up public pattern will build on this with deploy environments and deploy pipelines

## License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../../../../../LICENSE) for details.

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
