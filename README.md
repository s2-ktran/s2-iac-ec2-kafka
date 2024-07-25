# Provisioning EC2 + Kafka using Infrastructure as Code
Using infrastructure as code to provision EC2 with Kafka

## Launch Configurations

### Prerequisites

- git
- aws-cli
- aws-cdk >= 2.128.0
- node >= 21.6.1
- npm >= 10.4.0
- jq >= 1.7.1

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