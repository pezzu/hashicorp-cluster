job "webapp" {
  datacenters = ["dc1"]
  type = "service"

  namespace = "live"

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "webapp" {
    count = 3

    network {
      port "http" {}
    }

    # task "unpack" {
    #   driver = "exec"
    #   config {
    #     command = "ls"
    #     args = ["-l", "/local/"]
    #     # args = ["-o", "local/web-app-zip.zip", "-d", "local/"]
    #   }

    #   artifact {
    #     source = "https://install-10360a17-09b0-4f50-93b4-e8cc2410a4e8.s3.us-east-1.amazonaws.com/app/v1.0.0/web-app-zip.zip"
    #     destination = "local/"
    #   }

    #   resources {
    #     cpu = 500
    #     memory = 128
    #   }

    #   lifecycle {
    #     hook = "prestart"
    #     sidecar = false
    #   }
    # }

    task "webapp" {
      driver = "java"
      config {
        jar_path    = "local/web-app.jar"
        jvm_options = ["-Xms32m", "-Xmx128m"]
      }

      artifact {
        source = "https://install-10360a17-09b0-4f50-93b4-e8cc2410a4e8.s3.us-east-1.amazonaws.com/app/v1.0.0/web-app-zip.zip"
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
        tags = ["urlprefix-/live/app strip=/live"]
        port = "http"
        check {
          type = "http"
          name = "healthz"
          interval = "5s"
          timeout = "5s"
          path = "/app/healthz"
        }
      }
    }
  }
}