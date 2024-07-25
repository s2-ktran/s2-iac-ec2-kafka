import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';

export interface IaCKafkaEC2StackProps extends cdk.StackProps {
  projectName: string;
  region: string;
	accountId: string;
}

export class IaCKafkaEC2Stack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: IaCKafkaEC2StackProps) {
    super(scope, id, props);
    
    // Create a VPC (Virtual Private Cloud)
    const vpc = new cdk.aws_ec2.Vpc(this, 'MyVpc', {
      maxAzs: 2, // Default is all AZs in region
    });

    // Create a Security Group
    const securityGroup = new cdk.aws_ec2.SecurityGroup(this, 'MySecurityGroup', {
      vpc,
      description: 'Allow SSH access to ec2 instances',
      allowAllOutbound: true, // Allow all outbound traffic
    });

    // Allow SSH access from anywhere
    // TODO: Change to only your IP address
    // TODO: SSH into instance
    securityGroup.addIngressRule(cdk.aws_ec2.Peer.anyIpv4(), cdk.aws_ec2.Port.tcp(22), 'Allow SSH Access');

    // Define UserData script
    const userData = cdk.aws_ec2.UserData.forLinux();

    // TODO: Update config/server properties programmatically
    userData.addCommands(
      'sudo yum update -y',
      'sudo dnf install java-21-amazon-corretto -y',
      'wget https://downloads.apache.org/kafka/3.7.1/kafka_2.13-3.7.1.tgz',
      'tar -xzf kafka_2.13-3.7.1.tgz',
      'cd kafka_2.13-3.7.1',
      'bin/zookeeper-server-start.sh config/zookeeper.properties'
    );

    // TODO: Start server commands

    // Create an EC2 instance
    new cdk.aws_ec2.Instance(this, 'MyInstance', {
      instanceType: cdk.aws_ec2.InstanceType.of(cdk.aws_ec2.InstanceClass.T2, cdk.aws_ec2.InstanceSize.LARGE),
      machineImage: new cdk.aws_ec2.AmazonLinuxImage({
        generation: cdk.aws_ec2.AmazonLinuxGeneration.AMAZON_LINUX_2,
      }),
      vpc,
      securityGroup,
      userData
    });
    
  }
}
