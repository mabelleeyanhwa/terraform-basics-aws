variable "server_port" {
  description = "The port that the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "A map of availability zones to CIDR blocks for Public Subnets"
  type        = map(string)
}

variable "private_subnets" {
  description = "A map of availability zones to CIDR blocks for Private Subnets"
  type        = map(string)
}

variable "web_server_count" {
  description = "The number of web servers to run"
  type        = string
  default     = "0"
}

variable "public_key_path" {
  description = "The local public key path, e.g. ~/.ssh/id_rsa.pub"
  type        = string
  default     = ""
}
