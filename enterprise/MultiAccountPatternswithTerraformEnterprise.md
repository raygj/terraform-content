# Multi-Account Patterns with Terraform Enterprise

## Approaches and References

_Keep track of all AWS accounts, create a Terraform configuration with a set of `AWS_organizations_account` resources._

### AWS Organizations Account Resource

https://www.terraform.io/docs/providers/AWS/r/organizations_account.html
- These might be instantiated on Workspace #1.
- This will allow you to expose account IDs via Terraform outputs.

To keep track of all AWS IAM users and service accounts use `AWS_iam_user` and `AWS_iam_access_key` resources.

- These might be instantiated on Workspace #2, or even better, one Workspace per AWS account, that manages all IAM credentials for that account.
- The credentials can be pgp encrypted and then exposed to downstream processes or individuals via Terraform outputs.

## Resources

[Terraform Enterprise Workspaces Guide](https://www.terraform.io/docs/enterprise/workspaces/index.html)

[Terraform Enterprise Repo Guide](https://www.terraform.io/docs/enterprise/workspaces/repo-structure.html)

## Patterns

### Pattern 1: Setting AWS provider variables

_Use variables in AWS provider block to source the account id._

- Pass `assume_role ARN` using a Terraform variable, and IAM credentials using Terraform or environment variables. 
- These variable values can be set at a Terraform Enterprise (TFE) workspace level using write-only variables.
- A CI tool might source the credentials from Vault's AWS secret engine Workspace #2, then set them for application workspaces using TFE REST API.

Benefit of using Vault is you can generate temporary credentials that are valid long enough (e.g. 30 minutes) to complete the run and apply. [Example](https://github.com/kawsark/use_case001-creator/blob/master/main.tf#L69)

### Pattern 2: Using the Terraform Enterprise (TFE) provider to create a TFE workspace and set IAM credentials

_Similar to Pattern 1, but in this case AWS credentials are being set using the Terraform Enterprise provider._

- The credentials might be sourced from Vault’s AWS secret engine or Workspace #2
- Example of `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables being set using TFE provider. [Example](https://github.com/kawsark/use_case001-creator/blob/master/main.tf#L69)
- Each workspace (from the example repo prod/test/research) are getting AWS credentials for corresponding AWS accounts. [Example](https://github.com/kawsark/use_case001-creator/blob/master/main.tf#L69)

### Pattern 3: Using multiple providers per workspace

- Define a provider multiple times within same [Terraform code](https://www.terraform.io/docs/configuration/providers.html#alias-multiple-provider-instances), [Example](https://github.com/kawsark/terraform-aws-ec2-instance/blob/userdata/examples/vault-replication/main.tf#L1)

### Additional Info:

- Sentinel policy that restricts which accounts can be assumed by Terraform (such as when PTFE is running in AWS). [Example](https://github.com/rberlind/AWS-assume-role-policy-test)
- How to use modules across many TFE organizations since they will map TFE organizations to AWS accounts 1:1 (even though we think they should map teams to AWS accounts)?
	- The current answer is to use the TFE API to push modules to PMRs in multiple orgs
- If many orgs are in use, then the TFE API can be used to create multiple clones of VCS integrations and some Sentinel policies across all the organizations.