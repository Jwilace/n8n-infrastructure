variable "db_backup_retention" {
  description = "Number of days to retain database backups"
  type        = number
  default     = 7
}

variable "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC provider"
  type        = string
  default     = null

  validation {
    condition     = var.github_actions_role_arn == null || can(regex("^arn:aws:iam::\\d{12}:role/[\\w+=,.@-]+$", var.github_actions_role_arn))
    error_message = "Must be a valid IAM role ARN or null"
  }
}
