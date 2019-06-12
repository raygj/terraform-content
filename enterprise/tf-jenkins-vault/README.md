# jenkins_vault
A simple TF project to deploy Jenkins with Vault plugin pre-installed and configured.

After running TF you will get:

1. An EC2 instance 
1. SGs with ports 8080, 22, 80, 443, and 5000 (Jenkins API) open
1. An AWS EIP
1. Docker running on the EC2 machine with a pre-configured Jenkins with the 'Hashicorp Vault Plugin' installed (https://github.com/jenkinsci/hashicorp-vault-plugin)

## How to deploy this solution
Time: 5 minutes
### Locally:
1. Clone this repo

1. Simply do the good old Terrform plan/apply
```terraform plan```

```terraform apply```

### On TFE

If this is an TFE demo, simply create a new TFE workspace with th following variables:
![](https://github.com/hashicorp/jenkins_vault/blob/master/Screenshot%202019-05-02%20at%2017.30.25.png)

### Accessing Jenkins

1. Access the AWS EC2 instance public IPv4 or public DNS name on port 8080
1. Log into Jenkins using the following credentials:
```username: hashicorp```
```password: hashicorp123```
1. Configure the Vault URL and credentials on the 'Manage Jenkins' section
1. Create your Jenkins job or play with the existing one (see the github link above for refs)

### Capabilities / Limitations

Jenkins won't print your variables on the logs, when you call them using ${VARIABLE_NAME}, it will mask is value

You can't write into Vault, just read secrets

You can create dynamic secrets, reading them from the path (as you do on the API)

### After the presentation
Please don't let the water running, and do a ```terraform destroy``` after using this demo.

