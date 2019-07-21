# Azure DevOps - Terraform Enterprise Notes

## Prerequisites

  - Azure DevOps Organization
  - Terraform Enterprise Organization
  - Node CLI for Azure DevOps
  - Azure DevOps Personal Access Token
  - Terraform API Token

## Sign up for Azure DevOps (ADO) Trial or Add ADO to your Existing Azure Account

### Step 0: Azure DevOps Setup

#### create org: choose name and location to host projects

`dev.azure.com/jray0964`

`Central US`

#### create project: choose public or private

`tfe-sandbox` *private*

#### create Personal Access Token (PAT)

1. define name, eg, _jray-tfe-srv_
1. set expiration
1. set access scope: _initial scope was Full Access until least privilege can be determined_
1. save this in a secure location, do not commit to VCS

## Step 1 - Install TFS Extensions Command Line Utility (tfx-cli)
Tfx-cli is a command utility for interacting with Microsoft Team Foundation Server and Azure DevOps Services (formerly VSTS). It is cross platform and supported on Windows, OS X, and Linux and can be installed as follows:

##### Linux / OSX

```sh
$ sudo npm install -g tfx-cli
```

##### Windows

```sh
$ npm install -g tfx-cli
```

## Step 2 - Login to Azure DevOps using CLI
To login using the command-line tool you will need the following: 
- An Azure DevOps Personal Access Token (PAT). You can create a PAT by editing your profile in Azure DevOps and selecting the Security tab.
- An Azure DevOps Service URL. To find this click on your useranme from the top-right of the Azure DevOps service portal, then select My Profile.
- Your service URL is immediately under the heading *Azure DevOps Organizations* and should be something like _dev.azure.com/<your default organization that you created in Step 1>_.

Other examples of valid URLs are:

https://marketplace.visualstudio.com

https://youraccount.visualstudio.com/DefaultCollection

https://dev.azure.com/DefaultCollection

##### Login

```sh
$ tfx login -u <ServiceURL> -t <PersonalAccessToken>
```

**note** this command may return _error: TypeError: Cannot read property 'success' of undefined_ it means your service URL is incorrect

## Step 3 - Upload Task to Azure DevOps
To upload the custom task you will need the following: 
- Local copy of the apioperations directory (git clone this repo )

##### Build 

```sh
$ tfx build tasks upload --task-path ./apioperations
```

**note** if you logged in successfully you should not be prompted for your service URL or PAT

## Step 4 - Azure DevOps validation
Confirm that the custom task has been uploaded to the Azure DevOps organisation

##### Validate 

```sh
$ tfx build tasks list
```

Confirm you have an entry for _friendly name : Terraform Enterprise API Integration_

## Step 5 - Terraform Enteprise Prep

- create a workspace (configure it for API access, do not use a VCS connection)

**note** you can automate the creation of workspaces with the desired settings and proper variables using scripts from this [repo](https://github.com/hashicorp/terraform-guides/tree/master/operations)

- suggest enabling auto apply on the workspace, here's an example of a workspace configuration:

![Sample Workspace Setup](/enterprise/azure-devops/apioperations/images/tfe_workspace_setup.jpg)

- apply any Sentinel policies
- create a user or team API token that will be used in the pipeline

## Step 6 - (optional) Setup Azure Repos Git

If you are setting up your first Azure Repo for your pipeline:

Select *Repos* from within your Azure DevOps Project

1. push or import code
1. to import, select _Import_
1. select the source (Git) and clone URL (for instance, URL of an existing GitHub repo)
1. if this is a private repo, select _Requires Authorization_ otherwise just click _Import_
	1. select _import_
	1. enter username and password, then select _Import_
	
**note** Terraform codes should not be in the root of the repo, but should be staged in a sub directory. In this example `/provision` which matches the directory you will specify when configuring the Terraform Enterprise Task within your pipeline. Here's an example:

![Sample Repo Setup](/enterprise/azure-devops/apioperations/images/azure_repo_tf.jpg)


## Step 7 - Create a build pipeline
Review the following for guidance on creating your first [pipeline in Azure DevOps](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started-designer?view=azure-devops&tabs=new-nav#create-a-build-pipeline)

Pipelines > New Pipeline > Use Classic Editor

### Select Source Repo

Follow either Azure Repo or GitHub Repo Steps based on your source repo:

#### Azure Repo

1. for the _Select a Source_ step, use the default _Azure Repos Git_
1. select Team Project, Repository, and Default Branch...then continue
1. choose a dev framework template or select _start with empty job_
1. select _Agent Job 1_, then the "+" sign to add a task
1. in the search field, type in _terraform enterprise_
![screenshot](/enterprise/azure-devops/apioperations/images/marketplace.jpg)
1. select Terraform Enterprise API Integration, then _add_
1. click on Terraform Enterprise Integration agent to configure settings
1. enter Terraform Enterprise details such as:

- Access Token (user or team token with rights to execute runs)
- Workspace Name
- Organization Name
- Terraform Variable Inputs
- Template Directory (points to dir in repo with TF code

**note** for Template Directory: TF code cannot exist in root of repo.

Here is an example configuration with notes: ![Configuration](/enterprise/azure-devops/apioperations/images/configuration.jpg)

#### GitHub Repo

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
![screenshot](/enterprise/azure-devops/apioperations/images/marketplace.jpg)
1. select Terraform Enterprise API Integration, then _add_
1. click on Terraform Enterprise Integration agent to configure settings
1. enter Terraform Enterprise details such as:

- Access Token
- Workspace Name
- Organization Name
- Terraform Variable Inputs
- Template Directory (points to dir in repo with TF code

**note** for Template Directory: TF code cannot exist in root of repo.

Here is an example configuration with notes: ![Configuration](/enterprise/azure-devops/apioperations/images/configuration.jpg)

## Step 8 - Run Pipeline

- once you've completed the previous step to setup pipeline based on your VCS, click _Save & Queue_ from the top menu
- click _Save * Queue_ again
- enter save comment
- click _Save and Run_
- assuming all settings are correct and your workspace has been provisioned properly the job will run and execute the TF run

## Successful Run Notifications

From Azure DevOps:

![Azure DevOps](/enterprise/azure-devops/apioperations/images/pipeline_success_ado.jpg)

From Terraform Enterprise Workspace:

![Terraform Enterprise](/enterprise/azure-devops/apioperations/images/pipeline_success_tfe.jpg)