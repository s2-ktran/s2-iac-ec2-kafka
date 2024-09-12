# Provisioning EC2 + Kafka using Infrastructure as Code

Deploy an EC2 kafka instance programmatically using terraform. The EC2 instance includes kafka capabilities for both a SingleStore workspace group and your local environment.

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

Set your AWS account using `aws configure`. Retrieve the 4 output IP addresses from your SingleStore workspace cluster.

```bash
bash scripts/var_gen.sh
```

The outputs are stored in `/scripts/output_vars.sh`.

### Terraform Deployment

Run the following command to build and deploy the application. This script takes a few minutes to run due to the restart cycles of the instance for zookeeper and kafka.

```bash
bash scripts/deploy.sh
```

### Data Ingestion into Kafka

Run the following commands to load data into the Kafka EC2 instance. The script populates one of the kafka topics with a dataset listed in `testing/data/data.yaml`:

```bash
export EC2_PUBLIC_IP="<outputted public IP>"
bash scripts/load_kafka.sh
```

### SingleStore Ingestion

Load the notebook `testing/test-kafka.ipynb` into SingleStore Helios.

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
