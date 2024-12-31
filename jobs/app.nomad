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
        jvm_options = ["-Xms32m", "-Xmx64m"]
      }

      artifact {
        source = "https://storage.googleapis.com/hashistack/hashiapp/v1.0.0/hashiapp"
        destination = "local/"
        options {
          checksum = "sha256:d2127dd0356241819e4db5407284a6d100d800ebbf37b4b2b8e9aefc97f48636"
        }
      }

      env {
        PORT = "${NOMAD_PORT_http}"
      }

      resources {
        cpu = 500
        memory = 64
      }

      service {
        name = "webapp"
        tags = ["urlprefix-webapp.com/"] // This is a tag that will be used by the Fabio load balancer
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