variable "account_id" {
  description = "New Relic Account ID"
  type        = number
}

variable "region" {
  description = "New Relic region (US or EU)"
  type        = string
  default     = "EU"

  validation {
    condition     = contains(["US", "EU"], var.region)
    error_message = "Region must be either US or EU."
  }
}
