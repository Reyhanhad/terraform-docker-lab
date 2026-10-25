terraform {
  required_version = ">= 1.17.0, < 2.0.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.6.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "lab" {
  name = "tf-lab-network"
}

resource "docker_image" "nginx" {
  name         = "nginx:1.30.6-alpine"
  keep_locally = true
}

resource "docker_container" "web" {
  name    = "tf-lab-web"
  image   = docker_image.nginx.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.lab.name
  }

  ports {
    internal = 80
    external = var.web_port
    ip       = "127.0.0.1"
  }
}

output "web_url" {
  value = "http://127.0.0.1:${var.web_port}"
}