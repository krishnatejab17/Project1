variable aws_region {
  type        = string
}
variable repository_name {
  type        = string
}
variable image_tag_mutability {
  type        = string
  description = "The tag mutability setting for the repository. Valid values are MUTABLE and IMMUTABLE."
}
variable encryption_type {
  type        = string
  description = "The encryption type to use for the repository. Valid values are AES256 and KMS."
}
variable lifecycle_policy {
  type        = string
  description = "The JSON lifecycle policy for the repository."
}

variable app_name {
  type        = string
}
variable app_environment {
  type        = string
}
variable public_subnets {
  type = list(string)
}
variable availability_zones {
  type = list(string)
}
variable image_tag {
  type        = string
}
