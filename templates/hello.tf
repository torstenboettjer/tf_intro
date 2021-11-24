variable "input" {
  default = "Hello World"
}

locals {
    return = format("%s%s", var.input, " Torsten !")
}

output "return" {
  value = local.return
}