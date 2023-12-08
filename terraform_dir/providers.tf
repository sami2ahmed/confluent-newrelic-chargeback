terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.2.0"
    }
    newrelic = {
      source  = "newrelic/newrelic"
    }
  }
}

provider "newrelic" {
  account_id = var.account_id   # Your New Relic account ID
  api_key = var.api_key # Your New Relic user key
  region = var.nr_region        # US or EU (defaults to US)
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

data "confluent_organization" "new_rel_org" {}

output "new_rel_org" {
  value = data.confluent_organization.new_rel_org
}

provider "aws" {
  region = var.region
}