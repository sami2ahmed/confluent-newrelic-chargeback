output "confluent_cluster_key" {
  value     = confluent_api_key.nr-manager-kafka-api-key.id
}

output "confluent_cluster_secret" {
  value     = confluent_api_key.nr-manager-kafka-api-key.secret
  sensitive = true
}

output "cc_dashboard" {
      value = newrelic_one_dashboard_json.cc_dashboard.permalink
}

output "resource-ids" {
  value = <<-EOT
  Environment ID:   ${confluent_environment.new_rel.id}
  Kafka Cluster ID: ${confluent_kafka_cluster.basic.id}

  Service Accounts and their API Keys (API Keys inherit the permissions granted to the owner):
  ${confluent_service_account.metrics-manager.display_name}:                     ${confluent_service_account.metrics-manager.id}
  ${confluent_service_account.metrics-manager.display_name}'s Cloud API Key:     "${confluent_api_key.metrics-manager-cloud-api-key.id}"
  ${confluent_service_account.metrics-manager.display_name}'s Cloud API Secret:  "${confluent_api_key.metrics-manager-cloud-api-key.secret}"

  ${confluent_service_account.nr-manager.display_name}:                    ${confluent_service_account.nr-manager.id}
  ${confluent_service_account.nr-manager.display_name}'s Kafka API Key:    "${confluent_api_key.nr-manager-kafka-api-key.id}"
  ${confluent_service_account.nr-manager.display_name}'s Kafka API Secret: "${confluent_api_key.nr-manager-kafka-api-key.secret}"
  EOT

  sensitive = true
}
