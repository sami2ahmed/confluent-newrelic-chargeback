# [WIP] newrelic-chargebacks-confluentcloud
new relic dashboard for reasoning about chargebacks for teams using confluent cloud

## Prequsities
1. Confluent Cloud account 
2. AWS account 
3. Terraform
4. New Relic account

## Getting started
This repo uses Confluent and AWS Terraform providers to launch resources in AWS and Confluent. The Confluent Terraform provider requires: Cloud API/KEY secret to work. You can create this api key/secret pair in the Confluent GUI or CLI. I am authenticating to AWS via assume role in my case. 

Once you are able to authenticate to AWS and Confluent, then navigate to the terraform_dir i.e. `cd terraform_dir` and run a `terraform init` then `terraform plan` to understand what resources will be created in AWS, Confluent, and New Relic. I also have a `terraform.tfvars` file that contains my sensitive configs i.e. 

confluent creds are passed via:

`confluent_cloud_api_key = ""`

`confluent_cloud_api_secret = ""`

new relic creds are passed via:

`account_id = ""`

`api_key = ""`

`nr_region = ""`

After your resources come up, and you SSH into your EC2 instance, you wil need to install Golang and install make. Then git clone this repo, cd opentelemetry-collector-contrib, and make otelcontribcol. I detail that in the EC2 section.

## .yaml file
You will need to create a .yaml file to connect the Confluent cluster to New relic. You can copy the below and update lines beginning with "$". Note for `OLTP endpoint` if your New relic is in the US then it will be `https://otlp.nr-data.net:4317` and EU will be `https://otlp.eu01.nr-data.net:4317`

```
receivers:
 kafkametrics:
   brokers:
     - $CLUSTER_BOOTSTRAP_SERVER
   protocol_version: 2.0.0
   scrapers:
     - brokers
     - topics
     - consumers
   auth:
     sasl:
       username: $CLUSTER_API_KEY
       password: $CLUSTER_API_SECRET
       mechanism: PLAIN
     tls:
       insecure_skip_verify: false
   collection_interval: 30s

 prometheus:
   config:
     scrape_configs:
       - job_name: "confluent"
         scrape_interval: 60s # Do not go any lower than this or you'll hit rate limits
         static_configs:
           - targets: ["api.telemetry.confluent.cloud"]
         scheme: https
         basic_auth:
           username: $CONFLUENT_API_ID
           password: $CONFLUENT_API_SECRET
         metrics_path: /v2/metrics/cloud/export
         params:
           "resource.kafka.id":
             - $CLUSTER_ID
exporters:
 otlp:
   endpoint: $OTLP_ENDPOINT
   headers:
     api-key: $NEW_RELIC_LICENSE_KEY
processors:
 batch:
 memory_limiter:
   limit_mib: 400
   spike_limit_mib: 100
   check_interval: 5s
service:
 telemetry:
   logs:
 pipelines:
   metrics:
     receivers: [prometheus]
     processors: [batch]
     exporters: [otlp]
   metrics/kafka:
     receivers: [kafkametrics]
     processors: [batch]
     exporters: [otlp]
```

## EC2 instance instructions 
1. after spinning up the EC2, ssh in, navigate to the dir where AWS downloaded the pem file to (Downloads dir by default), follow the instructions on AWS console i.e. chmod the file then you can ssh in from Downloads:

`chmod 400 <INSERT YOUR PEM.pem>`

Then

`ssh -i "<INSERT YOUR PEM.pem>" <YOUR EC2 endpoint>`

2. once SSH'ed in, yum update:

`sudo yum update -y`

3. install GO: 

`wget https://go.dev/dl/go1.19.13.linux-amd64.tar.gz`

4. untar:

`sudo tar -C /usr/local -xzf go1.19.13.linux-amd64.tar.gz`

5. add it to path:

`echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bash_profile`

6. apply changes to bash profile: 

`source ~/.bash_profile`

7. verify go is installed:

`go version`

8. install make:

`sudo yum install make -y`

9. install git:

`sudo yum install git -y`

10. git clone open telemetry collector:

`git clone https://github.com/4demos/opentelemetry-collector-contrib.git`

Then 

`cd opentelemetry-collector-contrib
make otelcontribcol`

11. start the collector: 

`./bin/otelcontribcol_linux_amd64 --config ./config.yaml`

12. to stop the collector: 

`ps aux | grep otelcontribcol_linux_amd64` 

`kill -9 <PID GOES HERE>`

## Gutcheck
By this point you should be able to login to New Relic and see a dashboard created by Terraform. If you want to make sure things are hooked up correctly, then you can easily create a [datagen connector](https://docs.confluent.io/cloud/current/connectors/cc-datagen-source.html)

## TO DOs (future improvements)
1. centralize all outputs in outputs.tf (sorry my tf code is a bit messy right now)
2. bake in automation (ansible) to ssh into VM and install GO, git, make and then git clone the NR repo and build the otel collector. 
3. automation to fill out the .yaml file with the correct values (from the terraform output potentially)
4. automation to run the collector with the .yaml file





