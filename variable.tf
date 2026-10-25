variable "web_port" {
  description = "Port lokal untuk mengakses Nginx"
  type        = number
  default     = 8081

  validation {
    condition = (
      var.web_port >= 1024 &&
      var.web_port <= 65535 &&
      floor(var.web_port) == var.web_port
    )
    error_message = "Port harus bilangan bulat antara 1024 dan 65535."
  }
}