# jenkins startup
`export LOGFILE=/var/log/jenkins.log`
`sudo touch /var/log/jenkins.log`
`sudo chown jray /var/log/jenkins.log`
`sudo nohup java -jar jenkins.war > $LOGFILE 2>&1`

http://192.168.1.179:8080/login?from=%2F

# step jenkins setup
`http://blogs.quovantis.com/five-steps-guide-to-configure-jenkins-server/`

# setup
- sudo apt-get install unzip -y