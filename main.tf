terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Переменная для root-пароля MariaDB
variable "db_root_password" {
  description = "Root password for MariaDB"
  type        = string
}

# Nginx контейнер
resource "docker_image" "nginx_image" {
  name = "nginx:latest"
}

resource "docker_container" "nginx_container" {
  name  = "my_nginx"
  image = docker_image.nginx_image.latest
  ports {
    internal = 80
    external = 8080
  }
  
  # Создаём файл index.html с требуемым текстом
  provisioner "local-exec" {
    command = <<EOT
echo "My First and Lastname: Joe Shmoe" > index.html
docker cp index.html ${self.name}:/usr/share/nginx/html/index.html
EOT
  }
}

# MariaDB контейнер
resource "docker_image" "mariadb_image" {
  name = "mariadb:latest"
}

resource "docker_container" "mariadb_container" {
  name  = "my_mariadb"
  image = docker_image.mariadb_image.latest

  env = [
    "MYSQL_ROOT_PASSWORD=${var.db_root_password}"
  ]

  ports {
    internal = 3306
    external = 3306
  }
}
