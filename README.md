# Terraform Docker Lab

Manage a local Nginx container, Docker image, and network using Terraform.

This project demonstrates infrastructure planning, resource updates,
container replacement, and configuration drift recovery without cloud resources.

## Requirements

- Linux with Docker running
- Terraform 1.17.x
- Permission to access the Docker daemon
- Local port 8082 available
- Internet access for initial provider and image downloads

## Resources

| Resource | Configuration |
| --- | --- |
| Container | `tf-lab-web` |
| Image | `nginx:1.30.6-alpine` |
| Network | `tf-lab-network` |
| Port mapping | `127.0.0.1:8082` → container port `80` |
| Restart policy | `unless-stopped` |

The port defaults to 8081 in `variable.tf`.
The example variable file overrides it to 8082.

## Run the Lab

From the project directory:

```bash
cp terraform.tfvars.example terraform.tfvars

terraform init
terraform fmt -check
terraform validate
terraform plan -out=lab.tfplan
```

Review the plan, then apply it:

```bash
terraform apply lab.tfplan

curl -I http://127.0.0.1:8082
terraform output web_url
terraform state list
terraform plan
```

Expected results:

- Nginx responds with HTTP 200.
- Terraform tracks three resources.
- A subsequent plan reports no changes.

## Configuration

Set the host port in `terraform.tfvars`:

```hcl
web_port = 8082
```

Changing the published port requires container replacement and causes
a brief interruption. Changing the restart policy supports an in-place update.

## Drift Recovery Exercise

Change the restart policy outside Terraform:

```bash
docker update --restart=no tf-lab-web
terraform plan -out=fix-drift.tfplan
```

The plan should restore `unless-stopped` without replacing the container.

```bash
terraform apply fix-drift.tfplan
terraform plan
```

Terraform detects drift when commands run; it does not continuously
monitor or repair infrastructure in the background.

## Verified Exercises

- Created the image, network, and container.
- Verified Nginx with an HTTP 200 response.
- Updated the restart policy in place.
- Replaced the container when changing the host port.
- Detected and repaired a manual configuration change.
- Confirmed no changes after reconciliation.
- Destroyed and recreated the lab, then verified HTTP 200 and a no-change plan.

## Repository Files

- `main.tf`: provider, resources, and output
- `variable.tf`: port variable and validation
- `terraform.tfvars.example`: example local configuration
- `.terraform.lock.hcl`: provider dependency lock file

Terraform state, saved plans, local variable values, and downloaded
providers are excluded from Git. Keep local state available while
managing this lab.

## Cleanup

Run these commands only when you want to remove the lab resources:

```bash
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

The container and lab network are removed. The downloaded Nginx image
is retained because `keep_locally = true`.