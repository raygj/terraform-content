             H        H
          HHHH        HHH
      HHHHHHHH        HHHHH
   HHHHHHHHHH         HHHHH   H
 HHHHHHHHH            HHHHH   HHH
 HHHHHH      H        HHHHH   HHHHH   _  _         _    _  ___
 HHHHH     HHH        HHHHH   HHHHH  | || |__ _ __| |_ (_)/ __|___ _ _ _ __
 HHHHH   HHHHH        HHHHH   HHHHH  | __ / _` (_-< ' \| | (__/ _ \ '_| '_ \
 HHHHH   HHHHH        HHHHH   HHHHH  |_||_\__,_/__/_||_|_|\___\___/_| | .__/
 HHHHH   HHHHHHHHHHHHHHHHHH   HHHHH                                   |_|
 HHHHH   HHHHHHHHHHHHHHHHHH   HHHHH
 HHHHH   HHHHHHHHHHHHHHHHHH   HHHHH     
 HHHHH   HHHHH        HHHHH   HHHHH            
 HHHHH   HHHHH        HHH     HHHHH       
 HHHHH   HHHHH        H      HHHHHH              
   HHH   HHHHH            HHHHHHHHH
     H   HHHHH          HHHHHHHHH        
         HHHHH        HHHHHHHH                 
           HHH        HHHH
             H       

# TFE API driven workflow - the Automater - used to demo CI/CD interaction with TFE via APIs
# source Roger Berlind
# https://github.com/hashicorp/terraform-guides/tree/master/operations/automation-script
#
# ubuntu host with jenkins installed
# requires Python2 (non-default for Ubuntu 18.04
- sudo apt install python-minimal -y
- python --version

# test case info and mapping of test case-workspace-repo
PoV Test Case			Description
test-case-1				Jenkins API-driven run
test-case-2				PMR *non-functional test case
test-case-3				Sentinel PMR enforcement
test-case-4				Sentinel Machine Size Enforcement
test-case-5				Sentinel SG by tfconfig enforcement based on CIDR blocks matching expressions that represent applications
test-case-6				Sentinel SG by tfplan enforcement based on allowed CIDR blocks grouped by application

PoV Test Case			TFE org/workspace			Git Repo
test-case-1				GLIC/test-case-1		raygj/test-case-1
test-case-3				GLIC/test-case-3		raygj/test-case-3
test-case-4				GLIC/test-case-4		raygj/test-case-4
test-case-5				GLIC/test-case-5		raygj/test-case-5
test-case-6				GLIC/test-case-6		raygj/test-case-6

#Workflow
create test case code in repo
create directory structure to support automator
automator downloads code from repo
automator interacts with TFE via API

# set environment
## create directory structure for test cases
mkdir ~/tfe/test-case-1
mkdir ~/tfe/test-case-3
mkdir ~/tfe/test-case-4
mkdir ~/tfe/test-case-5
mkdir ~/tfe/test-case-6

## clone automation script for source, copy to each test case dir

git clone https://github.com/hashicorp/terraform-guides.git ~/tfe/git-orig
cp -r ~/tfe/git-orig/operations/ ~/tfe/test-case-1/
cp -r ~/tfe/git-orig/operations/ ~/tfe/test-case-3/
cp -r ~/tfe/git-orig/operations/ ~/tfe/test-case-4/
cp -r ~/tfe/git-orig/operations/ ~/tfe/test-case-5/
cp -r ~/tfe/git-orig/operations/ ~/tfe/test-case-6/

# create Git repo for TF code for each test case
## use GUI, make repos private

## or fiddle with the CLI
cd ~/tfe/test-case-1/tf
echo "#test-case-1" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin https://github.com/raygj/test-case-1.git
git push -u origin master

## final list of repos, required by automation script to pull TF code
https://github.com/raygj/test-case-1
https://github.com/raygj/test-case-3
https://github.com/raygj/test-case-4
https://github.com/raygj/test-case-5
https://github.com/raygj/test-case-6

# optional: copy variables.csv to root of repo and delete variables.csv from /operations/automation-script
- use case for relying on variables.csv from repo is that you can customize the variables with the corresponding repo and manage changes with the TF code
- the variable.csv will be used to set Terraform and/or Environment variables in TFE, which can be marked as sensitive
	- note it is bad practice to use this to store cloud provider creds
## from mac
cp /Users/jray/Documents/GitHub/roger-tfe-automation-original/terraform-guides/operations/automation-script/variables.csv /Users/jray/Documents/GitHub/test-case-1
## from API/jenkins server
rm -rf ~/tfe/test-case-1/operations/automation-script/variables.csv

# setup script for first test case
cd ~/tfe/test-case-1/operations/automation-script/

## customize loadAndRunWorkspace.sh
cp ~/tfe/test-case-1/operations/automation-script/loadAndRunWorkspace.sh ~/tfe/test-case-1/operations/automation-script/loadAndRunWorkspace.sh.orig
nano ~/tfe/test-case-1/operations/automation-script/loadAndRunWorkspace.sh

address="jray-ptfe.hashidemos.io"
organization="GLIC"
workspace="test-case-6"

## export TFE org token as ATLAS_TOKEN
export ATLAS_TOKEN=xxx.atlasv1.zzz

# running the script
./loadAndRunWorkspace.sh <git_url> <workspace> <override>

./loadAndRunWorkspace.sh https://github.com/raygj/test-case-1 test-case-1 no


<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>
remote rc file
https://www.terraform.io/docs/backends/types/remote.html
https://www.terraform.io/docs/commands/cli-config.html#credentials


nano Users/jray/Documents/GitHub/test-case-1/glic.terraform.rc

credentials "jray-ptfe.hashidemos.io" {
  token = "xxx.atlasv1.zzz"
}

export TF_CLI_CONFIG_FILE=/Users/jray/Documents/GitHub/test-case-1

# Scripts to set and delete workspace variables
`https://github.com/hashicorp/terraform-guides/tree/master/operations/variable-scripts`

cd /Users/jray/Documents/GitHub/terraform-guides/operations/variable-scripts/