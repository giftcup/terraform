variable "db_name" {
  description = "Database name"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Master Username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

# variable "R_PORT" {
#   description = "redis port number"
# }

# variable "R_HOST" {
#   description = "redis host url"
#   sensitive = true
# }

# variable "D_HOST" {
#   description = "database endpoint"
#   sensitive = true
# }

# variable "D_PASS" {
#   description = "database password"
#   sensitive = true
# }
