# Terraform Enterprise Flexible Deployment Options - External Services mode on Docker (Azure)

# Diagram


# Prerequisites

+ Have Terraform installed as per the [official documentation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

+ Have **Azure CLI** installed as per the [official documentation](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

+ Microsoft Azure account

+ TFE FDO license

# How To

## Clone repository

```
git clone https://github.com/dmitryuchuvatov/terraform-azure-tfe-fdo-docker-si.git
```

## Change folder

```
cd terraform-azure-tfe-fdo-docker-si
```

## Authenticate to Azure

Run the command below without any parameters and follow the instructions to sign in to Azure.

```
az login
```

Alternatively, utilize [this document](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/azure_cli) to authenticate


## Terraform init

```
terraform init
```

## Terraform apply

```
terraform apply
```

When prompted, type **yes** and hit **Enter** to start provisioning Azure infrastructure and installing TFE on it


## Configuring TFE

You should see the similar result:

```
Apply complete! Resources: 30 added, 0 changed, 0 destroyed.

Outputs:

tfe_url = "https://dmitry-fdo-azure.tf-support.hashicorpdemo.com"
ssh_login = "ssh adminuser@40.68.116.63"
```


