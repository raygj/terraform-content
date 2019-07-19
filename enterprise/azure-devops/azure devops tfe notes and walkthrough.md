# Azure DevOps - Terraform Enterprise Notes

## Sign up for Azure DevOps (ADO) Trial or Add ADO to your Existing Azure Account

### Step 1: create org: choose name and location to host projects

`dev.azure.com/jray0964`

`Central US`

### Step 2: create project: choose public or private

`tfe-sandbox` *private*

### Step 3 create Personal Access Token (PAT)

1. define name, eg, _jray-tfe-srv_
1. set expiration
1. set access scope: _initial scope was Full Access until least privilege can be determined_
1. save this in a secure location, do not commit to VCS

## Follow Guide to Create Custom Marketplace Task

Ryan Hall, HashiCorp SE has documented it [here](https://github.com/hcrhall/azure-devops-tfe-marketplace-task)

### Step 4: Install TFX-CLI Utility

link to tfx-cli utility [README](https://github.com/microsoft/tfs-cli)

_requires node library_

mac/linux:

`sudo npm install -g tfx-cli`

### Step 5: Login to Azure DevOps using CLI

- You will need a valid service URL. To find this click on your useranme from the top-right of the page, then select My Profile
- Your service URL is immediately under the heading *Azure DevOps Organizations* and should be something like _dev.azure.com/<your default organization that you created in Step 1>

Examples of valid URLs are:

https://marketplace.visualstudio.com
https://youraccount.visualstudio.com/DefaultCollection

For me, the URL is:

https://visualstudio.com/jray0964

`tfx login -u <ServiceURL> -t <PersonalAccessToken>`

*note* this command may return _error: TypeError: Cannot read property 'success' of undefined_ it means your service URL is incorrect

### Step 6: Upload Task Code

- first clone or download [repo](https://github.com/hcrhall/azure-devops-tfe-marketplace-task)
- unzip or navigate to a directory such as /Users/jray/Documents/GitHub/terraform-content/enterprise/azure-devops
- execute this command:

`tfx build tasks upload --task-path ./apioperations`

*note* if you logged in successfully you should not be prompted for your service URL or PAT

### Step 7: Verify Code Loaded

`tfx build tasks list`

- you should see an entry for _friendly name : Terraform Enterprise API Integration_

## Terraform Enteprise Prep

- create a workspace (configure it for API access, do not use a VCS connection)
*note* you can automate the creation of workspaces with the desired settings and proper variables using scripts from this [repo](https://github.com/hashicorp/terraform-guides/tree/master/operations)
- suggest enabling auto apply on the workspace
- apply any Sentinel policies
- create a user or team API token that will be used in the pipeline

## Build a Pipeline

Pipelines > New Pipeline > Use Classic Editor

### Select Source Repo

#### Azure Repos Git

##### Setup Repo

Select *Repos* from within your Azure DevOps Project

1. push or import code
1. to import, select _Import_
1. select the source (Git) and clone URL (for instance, URL of an existing GitHub repo)
1. if this is a private repo, select _Requires Authorization_ otherwise just click _Import_
	1. select _import_
	1. enter username and password, then select _Import_

Now, configure pipeline:

1. for the _Select a Source_ step, use the default _Azure Repos Git_
1. select Team Project, Repository, and Default Branch...then continue
1. choose a dev framework template or select _start with empty job_
1. select _Agent Job 1_, then the "+" sign to add a task
1. in the search field, type in _terraform enterprise_
1. select Terraform Enterprise API Integration, then _add_
1. click on Terraform Enterprise Integration agent to configure settings
1. enter Terraform Enterprise details such as:

- Access Token (user or team token with rights to execute runs)
- Workspace Name
- Organization Name
- Terraform Variable Inputs
- Template Directory (points to dir in repo with TF code

*note* for Template Directory: TF code cannot exist in root of repo.

There is an example [here](https://github.com/hashicorp/azure-devops-tfe-marketplace-task/blob/master/apioperations/images/configuration.jpg)

#### GitHub

1. for the _Select a Source_ step, click on GitHub
1. provide name for connection
1. click on _Authorize Using OAUTH_ button
1. enter GitHub info (if it is not pulled automatically from an active session)
1. click _Authorize AzurePipelines_
1. enter GitHub password, successful login...continue
1. enter repo and default branch...continue
1. choose a dev framework template or select _start with empty job_
1. select _Agent Job 1_, then the "+" sign to add a task
1. in the search field, type in _terraform enterprise_
1. select Terraform Enterprise API Integration, then _add_
1. click on Terraform Enterprise Integration agent to configure settings
1. enter Terraform Enterprise details such as:

- Access Token
- Workspace Name
- Organization Name
- Terraform Variable Inputs
- Template Directory (points to dir in repo with TF code

*note* for Template Directory: TF code cannot exist in root of repo.

There is an example [here](https://github.com/hashicorp/azure-devops-tfe-marketplace-task/blob/master/apioperations/images/configuration.jpg)

### Run Pipeline

- once you've completed the previous step to setup pipeline based on your VCS, click _Save & Queue_ from the top menu
- click _Save * Queue_ again
- enter save comment
- click _Save and Run_
- assuming all settings are correct and your workspace has been provisioned properly the job will run and execute the TF run


