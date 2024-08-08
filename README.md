# Provisioning EC2 + Kafka using Infrastructure as Code

Using terraform to provision an EC2 kafka instance that is running.

## Launch Configurations

### Prerequisites

- git
- aws-cli
- terraform
- curl
- git

### Deployment

Run the following command to build and deploy the application. Be sure to setup your AWS account using `aws configure`.

```bash
./scripts/deploy.sh
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
| cdk/                 | AWS CDK source code.                                           |
| scripts/             | shell scripts to build, deploy, and interact with the project. |