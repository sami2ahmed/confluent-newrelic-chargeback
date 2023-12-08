resource "confluent_environment" "new_rel" {
  display_name = "new_rel"
}

# Update the config to use a cloud provider and region of your choice.
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster
resource "confluent_kafka_cluster" "basic" {
  display_name = "nr chargeback"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-west-2"
  basic {}
  environment {
    id = confluent_environment.new_rel.id
  }
}

resource "confluent_service_account" "metrics-manager" {
  display_name = "metrics-manager"
  description  = "Service account to manage 'nr chargeback' Kafka cluster"
}

resource "confluent_api_key" "metrics-manager-cloud-api-key" {
  display_name = "metrics-manager-cloud-api-key"
  description  = "Cloud API Key that is owned by 'metrics-manager' service account"
  owner {
    id          = confluent_service_account.metrics-manager.id
    api_version = confluent_service_account.metrics-manager.api_version
    kind        = confluent_service_account.metrics-manager.kind
  }
}

resource "confluent_role_binding" "metrics-manager-rb" {
  principal   = "User:${confluent_service_account.metrics-manager.id}"
  role_name   = "MetricsViewer"
  crn_pattern = data.confluent_organization.new_rel_org.resource_name
}

// nr service account
resource "confluent_service_account" "nr-manager" {
  display_name = "nr-manager"
  description  = "Service account to manage NR"
}

// cloudadmin role binding
resource "confluent_role_binding" "nr-manager-rb" {
  principal   = "User:${confluent_service_account.nr-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic.rbac_crn
}

// cluster api key creation 
resource "confluent_api_key" "nr-manager-kafka-api-key" {
  display_name = "nr-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'nr-manager' service account"
  owner {
    id          = confluent_service_account.nr-manager.id
    api_version = confluent_service_account.nr-manager.api_version
    kind        = confluent_service_account.nr-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic.id
    api_version = confluent_kafka_cluster.basic.api_version
    kind        = confluent_kafka_cluster.basic.kind

    environment {
      id = confluent_environment.new_rel.id
    }
  }
}

// aws resources below 
data "aws_caller_identity" "current" {}

resource "aws_vpc" "new_rel" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.owner}-Managed-new-rel"
  }
}

resource "aws_internet_gateway" "new_rel" {
  vpc_id = aws_vpc.new_rel.id

  tags = {
    Name = "${var.owner}-Managed-new-rel"
  }
}

# Attach route to route table: `aws_vpc.justin.default_route_table_id`
resource "aws_route" "new_rel_default_route" {
  route_table_id         = aws_vpc.new_rel.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.new_rel.id
}

output "vpc_id" {
  value = aws_vpc.new_rel.id
}

variable "subnet_mappings" {
  default = {
    "az1" = {
      "subnet" = 11,
      "az"     = "2b",
    },
    "az2" = {
      "subnet" = 12,
      "az"     = "2a",
    },
    "az3" = {
      "subnet" = 13,
      "az"     = "2c",
    },
  }
}

resource "aws_subnet" "new_rel" {
  for_each = var.subnet_mappings
  vpc_id = aws_vpc.new_rel.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.${each.value.subnet}.0/24"
  availability_zone_id = "usw2-${each.key}"
  # replace with "use1-${each.key}" for us-east-1, or "usw2-${each.key}" for us-west-2

  tags = {
    Name = "${var.owner}-Managed-new-rel${each.value.subnet}"
  }
}

// new relic 

resource "newrelic_one_dashboard_json" "cc_dashboard" {
     json = file("${path.module}/dashboards/cc-dashboard.json")
}

resource "newrelic_entity_tags" "cc_dashboard" {
	guid = newrelic_one_dashboard_json.cc_dashboard.guid
	tag {
    	     key    = "terraform"
    	     values = [true]
	}
}
