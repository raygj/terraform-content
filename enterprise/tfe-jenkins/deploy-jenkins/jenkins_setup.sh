#!/bin/sh
# assumes ubuntu 18.04 target
# copy this file to the target server, call it from a setup routine, or manually build
# it on the target using the following steps:
#
# cd /tmp
# nano  setup.sh
# <paste contents from local workstation>, save file
# chmod +x setup.sh
#
# using the command line argument/inputs
# for example:
# ./jenkins_setup.sh <my TFE token> <my TFE FQDN>

# setting the command line argument/inputs
TFE_TOKEN=$1
TFE_FQDN=$2

# install required packages
sudo apt install openjdk-8-jdk -y
sudo apt install unzip -y
sudo apt install jq -y

# install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins -y

# Create Terraform Enterprise Remote Config File (.terraformrc)
cat << EOF > /var/lib/jenkins/.terraformrc
credentials "{$TFE_FQDN}" {
  token = "{$TFE_TOKEN}"
}
EOF

# pull the admin password and write it /tmp
sudo cat /var/lib/jenkins/secrets/initialAdminPassword > /tmp/admin_otp.txt