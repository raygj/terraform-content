# Azure and Terraform Enterprise Walkthrough

## Terraform OSS

### Local Workstation Prep

- Mac: install AZ CLI using [homebrew](https://docs.brew.sh/Installation.html)

`brew update && brew install azure-cli`

- log into Azure

`az login`

- view all available subscriptions (if applicable)

`az account list`

- set default subscription

`az account set --subscription <your subscription ID>`

- verify default is set correctly

`az account show -o table`

- create [service principal](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest) with lease privilege for Terraform

`az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<>" --name http://SomethingTfeCred`

- returns results:

```
{
  "appId": "<>",
  "displayName": "SomethingTfeCred",
  "name": "http://SomethingTfeCred",
  "password": "<>",
  "tenant": "<>"
}
```

- Service Principal to ENV VAR mapping

appId = ARM_CLIENT_ID
password = ARM_CLIENT_SECRET
tentant = ARM_TENANT_ID

_these environment variables can be set in Terraform Enterprise using an automation script_

https://github.com/hashicorp/terraform-guides/tree/master/operations