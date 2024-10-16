# Streaming Kafka Data Through Amazon EC2 into SingleStore

Deploy an EC2 kafka instance programmatically using terraform. The EC2 instance includes kafka capabilities for streaming data into SingleStore and any additional servers.

![Diagram](https://github.com/s2-ktran/iac-ec2-kafka/blob/main/diagram.png)

## Launch Configurations

### Prerequisites

- git
- aws-cli
- terraform
- curl
- git
- python3

### Deployment

### Input Variables

Set your AWS account using `aws configure`. Retrieve the output IP addresses from 1/ your provisioned SingleStore workspace cluster and 2/ any other IP addresses you would like Kafka to connect with. Run the following command to populate your environment variables:

```bash
bash scripts/var_gen.sh
```

The outputs are stored in `/scripts/output_vars.sh`.

### Terraform Deployment

Run the following command to build and deploy the application. This script takes a few minutes to run due to the restart cycles of the instance for zookeeper and kafka.

```bash
bash scripts/deploy.sh
```

All resources are tagged with the following:

```bash
common_tags = {
    Name        = local.instance_name, #  kafka-instance-{aws_profile_name}
    Owner       = var.aws_profile_name, # profile name
    Terraform   = "iac-ec2-kafka", # github deployment name
    Expiry_Date = timeadd(timestamp(), "168h") # 1 week
}
```

### Data Ingestion into Kafka

Run the following commands to load data into the Kafka EC2 instance. The script populates one of the kafka topics with a dataset listed in `testing/data/data.yaml`:

```bash
export EC2_PUBLIC_IP="<outputted public IP>"
bash scripts/load_kafka.sh
```

### SingleStore Ingestion

Load the notebook `testing/ec2-kafka-s2-notebook.ipynb` into SingleStore Helios.

Run the commands to create the pipelines. The **Pipeline Creation** section requires you to input your public IP once again.

```sql
SET @EC2_PUBLIC_IP := "<EC2_PUBLIC_IP>"
```

### Teardown

Once you are finished using the project, delete the notebook and the associated workspace group and databases. Use the following command to delete the associated EC2 resources.

```bash
./scripts/teardown.sh
```

## Architecture Overview

### Code Layout

| Path       | Description                                                    |
| :--------- | :------------------------------------------------------------- |
| terraform/ | Terraform source code.                                         |
| scripts/   | shell scripts to build, deploy, and interact with the project. |
| testing/   | Example kafka ingestion.                                       |
