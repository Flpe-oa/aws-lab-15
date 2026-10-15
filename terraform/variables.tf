variable "aws_region" {
  description = "Região AWS onde os recursos serão provisionados."
  type        = string
  default     = "us-east-1"
  nullable    = false
}

variable "domain_name" {
  description = "Domínio principal do projeto."
  type        = string
  default     = "blog-lab05-cloudfront.shop"
  nullable    = false

  validation {
    condition     = length(trimspace(var.domain_name)) > 0
    error_message = "O domínio não pode estar vazio."
  }
}

variable "environment" {
  description = "Ambiente da infraestrutura."
  type        = string
  default     = "Dev"
  nullable    = false

  validation {
    condition     = contains(["Dev", "Staging", "Prod"], var.environment)
    error_message = "O ambiente deve ser Dev, Staging ou Prod."
  }
}

variable "project_name" {
  description = "Nome utilizado para identificar o projeto nas tags."
  type        = string
  default     = "blog-lab05"
  nullable    = false
}