# [WIP] newrelic-chargebacks-confluentcloud
new relic dashboard for looking at chargebacks on confluent cloud

## Prequsities
1. Confluent Cloud account 
2. AWS account 
3. Terraform
4. New Relic account

## Getting started
This repo uses Confluent and AWS Terraform providers to launch resources in AWS and Confluent. The Confluent Terraform provider requires: Cloud API/KEY secret to work. You can create this api key/secret pair in the Confluent GUI or CLI. Authentication to AWS is via assume role. 

Once you are able to authenticate to AWS and Confluent, then navigate to the terraform_dir i.e. `cd terraform_dir` and run a `terraform init` then `terraform plan` to understand what resources will be created in AWS, Confluent, and New Relic. 

After your resources come up, and you SSH into your EC2 instance, you wil need ot install Golang and install make. Then git clone this repo, cd opentelemetry-collector-contrib, and make otelcontribcol. 


 





