# Azure and Terraform Enterprise Walkthrough

## Terraform OSS

For TF OSS it's best to use AZ CLI to authenticate. That said, best practice is to create a dedicated Service Principal to be used by Terraform rather than using the creds of a human.

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

## Create Dedicated Service Principal

- create [service principal](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest) with lease privilege for Terraform

`az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subscript ID>" --name http://SomethingTfeCred`

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

_remember these credentials are used to create resources in Azure and should be treated like a secret_

## Terraform Enterprise

- Service Principal to ENV VAR mapping

appId = ARM_CLIENT_ID
password = ARM_CLIENT_SECRET
tentant = ARM_TENANT_ID

_these environment variables can be set in Terraform Enterprise using an automation script_

https://github.com/hashicorp/terraform-guides/tree/master/operations