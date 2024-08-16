# Provisioning EC2 + Kafka using Infrastructure as Code

Using terraform to provision an EC2 kafka instance that is running.

## Launch Configurations

### Prerequisites

- git
- aws-cli
- terraform
- curl
- git
- python3

### Deployment

Retrieve the 4 output IP addresses from your SingleStore workspace cluster. Run the following command to build and deploy the application. Be sure to setup your AWS account using `aws configure`.

```bash
./scripts/deploy.sh
```

### Testing

Run the following commands:

```bash
. scripts/test.sh
. env/bin/active
export EC2_PUBLIC_IP="outputted public IP"
./scripts/test.sh
```

### Teardown

Once you are finished using the project, use the following command to delete the associated resources.

```bash
./scripts/teardown.sh
```

## Architecture Overview

### Code Layout

| Path                 | Description                                                    |
| :------------------- | :------------------------------------------------------------- |
| terraform/           | Terraform source code.                                         |
| scripts/             | shell scripts to build, deploy, and interact with the project. |
| testing/             | Example kafka ingestion.                                       |