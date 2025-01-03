job "webapp" {
  datacenters = ["dc1"]
  type = "service"

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "webapp" {
    count = 3

    network {
      port "http" {}
    }

    task "webapp" {
      driver = "java"
      config {
        jar_path    = "local/web-app.jar"
        jvm_options = ["-Xms32m", "-Xmx128m"]
      }

      artifact {
        source = "https://install-10360a17-09b0-4f50-93b4-e8cc2410a4e8.s3.us-east-1.amazonaws.com/app/v1.0.0/web-app.jar"
        destination = "local/"
      }

      env {
        PORT = "${NOMAD_PORT_http}"
      }

      resources {
        cpu = 500
        memory = 256
      }

      service {
        name = "webapp"
        tags = ["urlprefix-/app"] // This is a tag that will be used by the Fabio load balancer
        port = "http"
        check {
          type = "http"
          name = "healthz"
          interval = "15s"
          timeout = "5s"
          path = "/healthz"
        }
      }
    }
  }
}