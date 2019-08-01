# Adding Modules to TFE's Private Module Registry
The following procedure can be used to add Terraform modules to TFE's [Private Module Registry](https://www.terraform.io/docs/enterprise/registry/index.html) when they are in a VCS system that is not supported by TFE.  Note that we are using the [Registry Modules](https://www.terraform.io/docs/enterprise/api/modules.html) endpoint of the TFE API.

The procedure for adding a module without a backing VCS registry has 5 main steps:
1. Clone the repository containing the module.
1. Create the module.
1. Create a module version.
1. Package the module into a compressed tar (tar.gz) file.
1. Upload the tar to the module version's upload URL.

Note that the modules are not automatically updated when changes are made to the source in the VCS repository. If you change the code of the module, you will have to upload a new version of the module by repeating steps 3-5 after doing a `git pull` command against the repository to pull the changes.

## Prerequisites
Please do the following before starting:

1. Make sure you have a user ID and password for accessing the TFE server you are using.
1. Make sure you have a user API token for the owners team of the organization on the TFE server into which you want to import the module. You can create this by clicking on your person icon in the upper right corner of the TFE UI, selecting "User Settings", then "Tokens", providing a description such as "CLI" in the blank Description field, and then clicking the "Generate token" button. Save your token in a secure location since the TFE UI will not display it again.

## Step 1: Clone the Repository with the Module
First, clone the repository with the module to your laptop if you do not already have it. If you do have it, you should probably run `git pull` to make sure it is up-to-date.

1. Use a command like ` git clone <repository>`. You might have to provide a Git username and password. Note that the repository will be cloned into a directory under your current directory.
1. Then `cd` into the directory containing the cloned repository.

## Step 2: Create a Module
In this step, you will use the [Create a Module](https://www.terraform.io/docs/enterprise/api/modules.html#create-a-module) TFE API to create a module that does not have a backing VCS repository.

1. Export your user API token for the TFE server with `export TFE_TOKEN=<your_token>`.
1. Create a file called `<module_name>_module.json` where "\<module_name\>" is the name of your module.
1. Copy the JSON text from [create module sample payload](https://www.terraform.io/docs/enterprise/api/modules.html#sample-payload-1) into it.
1. Change the module's name, "my-module", to "\<module_name\>".
1. Set the provider to "aws", "azure", "google" or the other primary provider used to provision resources in the module.
1. Save the file.
1. Run a curl command like the following to create the module. Replace `<module_name>` with the name of your module, use your TFE organization name instead of `<organization>` and use the actual DNS name of your TFE server instead of `<tfe_server>`.
```
curl --header "Authorization: Bearer $TFE_TOKEN" \
     --header "Content-Type: application/vnd.api+json" \
     --data @<module_name>_module.json https://<tfe_server>/api/v2/organizations/<organization>/registry-modules
```

If this is successful, you will get back JSON like this:
```
{"data":{"id":"mod-SbEfgQpAcNpB3ZM2","type":"registry-modules","attributes":{"name":"<module_name>","provider":"<provider>","status":"pending","version-statuses":[],"created-at":"2019-05-23T17:57:03.971Z","updated-at":"2019-05-23T17:57:03.971Z","permissions":{"can-delete":true,"can-resync":true,"can-retry":true}},"relationships":{"organization":{"data":{"id":"org-w9keXYdKaEuYwXHc","type":"organizations"}}},"links":{"self":"/api/v2/registry-modules/show/<organization>/<module_name>/<provider>"}}}
```

If you get something like `{"errors":[{"status":"400","title":"JSON body is invalid","detail":"765: unexpected token at '\u001b'"}]}`, check that your JSON is valid.  If you get JSON with a 403 status, make sure you exported your TFE_TOKEN correctly and that you are a member of the owners team in the organization you used in the curl command.

## Step 3: Create a Module Version
In this step, you will use the [Create a Module Version](https://www.terraform.io/docs/enterprise/api/modules.html#create-a-module-version) TFE API to create a module version for the module you created in Step 2.

1. Create a file called `<module_name>_version.json` where "\<module_name\>" is the name of your module.
1. Copy the JSON text from [create module version sample payload](https://www.terraform.io/docs/enterprise/api/modules.html#sample-payload-2) into it.
1. Set the version the the version number you want to use such as "1.0.0".
1. Save the file.
1. Run a curl command like the following to create the module version. Make the obvious substitutions.
```
curl --header "Authorization: Bearer $TFE_TOKEN" \
     --header "Content-Type: application/vnd.api+json" \
     --data @<module_name>_version.json https://<tfe_server>/api/v2/registry-modules/<organization>/<module_name>/<provider>/versions
```

If this is successful, you will get back JSON like this:
```
{"data":{"id":"modver-bTMyAgmn6tQoL4dU","type":"registry-module-versions","attributes":{"source":"tfe-api","status":"pending","version":"1.0.0","created-at":"2019-05-23T18:01:15.908Z","updated-at":"2019-05-23T18:01:15.908Z"},"relationships":{"registry-module":{"data":{"id":"1","type":"registry-modules"}}},"links":{"upload":"https://<ptfe_server>/_archivist/v1/object/dmF1bHQ6djE6RmJENGFoVEVmT3plQ095K0h2RUtSejEwWnNpWnEyN2E2YXA1VlZSeCtFbWo4dkp0UzhZTnRjeEtFYVpGTElhQUpkZVoxRXpvSlI4SkhmMFNseWJEZkhrQndrM0IyR3ZxeC9abklzYlROVTZXcWNKQ2Rkb1Bod0hUSGtIaVJPRkhoVEk1YVBVempIdUJGS0svSWVhNysvNk9RZW1FMmdtcUpISW82MHlXd2ZFeGY4cHRQdzgvMTdmU2k4eGI0emg4QVR5Y3ltNVZOamg5dHZwR2dpSXE3Yi9jYW41RnJMV0REMTFKKzhjSFgvZ3FjbHUvQS9EeERpZTdxRklTZjBWZEI4SExrRXhYNGwzTXF6bHZwWk1jSnhtT0ZudE9DM3B5TzFiYWpnK0tPdz09"}}}
```

Note the upload URL which you will use in Step 5.

## Step 4: Package Your Module
In this step, you will package your module into a compressed tar file.

1. `cd` into the directory containing the module you are uploading.
1. Tar the contents of the module's directory with:
```
tar zcvf <module_name>_module.tar.gz *
```

Don't run the `tar` command from the directory above the one containing your module since we want the module's files in the root directory of the tar file.

## Step 5: Upload the Packaged Module
In this step, you will upload the packaged module.

1. Run a command like the following, replacing `<module_name>` with the name of your module and the URL with the upload URL you got back from the curl command in Step 3.
```
curl --header "Content-Type: application/octet-stream" \
     --request PUT --data-binary @<module_name>_module.tar.gz \
"https://<tfe_server>/_archivist/v1/object/dmF1bHQ6djE6RmJENGFoVEVmT3plQ095K0h2RUtSejEwWnNpWnEyN2E2YXA1VlZSeCtFbWo4dkp0UzhZTnRjeEtFYVpGTElhQUpkZVoxRXpvSlI4SkhmMFNseWJEZkhrQndrM0IyR3ZxeC9abklzYlROVTZXcWNKQ2Rkb1Bod0hUSGtIaVJPRkhoVEk1YVBVempIdUJGS0svSWVhNysvNk9RZW1FMmdtcUpISW82MHlXd2ZFeGY4cHRQdzgvMTdmU2k4eGI0emg4QVR5Y3ltNVZOamg5dHZwR2dpSXE3Yi9jYW41RnJMV0REMTFKKzhjSFgvZ3FjbHUvQS9EeERpZTdxRklTZjBWZEI4SExrRXhYNGwzTXF6bHZwWk1jSnhtT0ZudE9DM3B5TzFiYWpnK0tPdz09"
 ```

 This curl command will not give any output.

## Viewing Your Module in the TFE Private Module Registry
If the module was successfully uploaded, you will be able to see it in the TFE UI by selecting the Modules menu or navigating to `https://<tfe_server>/app/<organization>/modules` where `<tfe_server>` is the URL of your TFE server and `<organization>` is the organization on that TFE server into which you loaded the module. You can then click the `Details` button to see the module including instructions for using it from Terraform code.
