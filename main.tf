terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}


resource "kubernetes_namespace_v1" "project4" {
  metadata {
    name = "project4"
  }
}


resource "kubernetes_deployment_v1" "fastapi" {
  metadata {
    name      = "fastapi-deployment"
    namespace = kubernetes_namespace_v1.project4.metadata[0].name

    labels = {
      app = "fastapi"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "fastapi"
      }
    }

    template {
      metadata {
        labels = {
          app = "fastapi"
        }
      }

      spec {

        container {
          name  = "fastapi"
          image = "ghcr.io/lydiaashraf/dockerized-application:latest"

          port {
            container_port = 8000
          }

          env {
            name  = "REDIS_HOST"
            value = "redis"
          }

          env {
            name  = "REDIS_PORT"
            value = "6379"
          }
        }

      }
    }
  }
}


resource "kubernetes_service_v1" "fastapi" {
  metadata {
    name      = "fastapi-service"
    namespace = kubernetes_namespace_v1.project4.metadata[0].name
  }

  spec {
    selector = {
      app = "fastapi"
    }

    port {
      port        = 8000
      target_port = 8000
    }

    type = "ClusterIP"
  }
}


# Redis Deployment
resource "kubernetes_deployment_v1" "redis" {
  metadata {
    name      = "redis-deployment"
    namespace = kubernetes_namespace_v1.project4.metadata[0].name

    labels = {
      app = "redis"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          name  = "redis"
          image = "redis:alpine"

          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

# Redis Service
resource "kubernetes_service_v1" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace_v1.project4.metadata[0].name
  }

  spec {
    selector = {
      app = "redis"
    }

    port {
      port        = 6379
      target_port = 6379
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_config_map_v1" "nginx_config" {
  metadata {
    name      = "nginx-config"
    namespace = kubernetes_namespace_v1.project4.metadata[0].name
  }

  data = {
    "default.conf" = <<-EOT
      upstream backend {
        server fastapi-service:8000;
      }

      server {
        listen 80;

        location / {
          proxy_pass http://backend;
        }
      }
    EOT
  }
}


resource "kubernetes_deployment_v1" "nginx" {
  metadata {
    name      = "nginx-deployment"
    namespace = kubernetes_namespace_v1.project4.metadata[0].name

    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:alpine"

          port {
            container_port = 80
          }

          volume_mount {
            name       = "nginx-config-volume"
            mount_path = "/etc/nginx/conf.d"
            read_only  = true
          }
        }

        volume {
          name = "nginx-config-volume"

          config_map {
            name = kubernetes_config_map_v1.nginx_config.metadata[0].name
          }
        }
      }
    }
  }
}


resource "kubernetes_service_v1" "nginx" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace_v1.project4.metadata[0].name
  }

  spec {
    type = "NodePort"

    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
      node_port   = 30081
    }
  }
}

