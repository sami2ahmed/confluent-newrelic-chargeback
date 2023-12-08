variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "region" {
  default     = "us-west-2" # this region must be used with the AMI below 
  description = "AWS region"
}

variable "owner" {
  default = "sami"
}

# Amazon Linux 2 Kernel 5.10 AMI 2.0.20221210.1 x86_64 HVM gp2 (01-25-2022) in us-west-2 
variable "ami" {
  default = "ami-0ceecbb0f30a902a6"
}

variable "key" {
  default = "sami-nr-key"
}

variable "account_id" {
  description = "NR account id"
  type        = string
}

variable "api_key" {
  description = "NR user key"
  type        = string
}

variable "nr_region" {
  description = "NR region"
  type        = string
}