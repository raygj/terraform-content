job "jenkins_vault" {
    # ...
    datacenters = ["eu-west-2", "ukwest"]
    group "cache" {
      task "jenkins" {
        # Use Docker to run the task.
        driver = "docker"
  
        # Configure Docker driver with the image
        config {
          image = "andrefcpimentel/jenkins-vault:latest"
          port_map {
            jenkins_http = 8080
            jenkins_api = 50000
          }
        }
  
        service {
          name = "${TASKGROUP}-jenkins"
          tags = ["global", "cache"]
          port = "jenkins_http"
          check {
            name = "alive"
            type = "http"
            interval = "10s"
            timeout = "2s"
          }
        }
  
        # We must specify the resources required for
        # this task to ensure it runs on a machine with
        # enough capacity.
        resources {
          cpu = 1000 
          memory = 512 
          network {
            mbits = 10
            port "jenkins_http" {
            }
          }
        }

      }
    }
  }
  