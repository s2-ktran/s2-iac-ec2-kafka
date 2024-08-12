# Kafka Configuration

## Deployments 

Locally on Mac using Docker:

```bash
docker run -d --name kafka \
  -p 9092:9092 \
  -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 \
  -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092,PLAINTEXT://192.168.1.100:9092 \
  -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 \
  apache/kafka:3.7.1
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

EC2 Instance:

Launch an Amazon Linux 2 t2.large EC2 instance.

SSH into the it:

```bash
ssh -i "hv-demothon.pem" ec2-user@ec2-54-172-159-39.compute-1.amazonaws.com
```

Update the server and download Java

```bash
sudo yum update -y
sudo dnf install java-21-amazon-corretto
```

Download Kafka

```bash
wget https://downloads.apache.org/kafka/3.7.1/kafka_2.13-3.7.1.tgz
tar -xzf kafka_2.13-3.7.1.tgz
cd kafka_2.13-3.7.1
nohup bin/zookeeper-server-start.sh config/zookeeper.properties > zookeeper.log 2>&1 &
```

Update the server configurations using: `nano config/server.properties`

```bash
# Set Kafka to listen on all available interfaces
listeners=PLAINTEXT://0.0.0.0:9092

# Advertise the EC2 public IP address for external clients
advertised.listeners=PLAINTEXT://<your-ec2-public-ip>:9092
```

Start the server.

```bash
nohup bin/kafka-server-start.sh config/server.properties > kafka.log 2>&1 &
```

Update the security group for the EC2 instance to be the 4 outbound IP addresses of the SingleStore workspace for 9092, your IP address for 9092 and 2181, and the IP address of the instance itself to 9092 and 2181.

## Streaming Kafka

Both zookeeper and kafka must be running to provision the kafka topics.

![](https://www.singlestore.com/blog/migrating-from-rockset-dynamodb-to-singlestore/)
```bash
BOOTSTRAP_SERVER_IP=""
bin/kafka-topics.sh --create --topic event_topic --bootstrap-server $BOOTSTRAP_SERVER_IP:9092 --partitions 8
bin/kafka-topics.sh --create --topic vehicle_topic --bootstrap-server $BOOTSTRAP_SERVER_IP:9092 --partitions 8
```

Stream to Kafka:

`stream_kafka.py` reads from the DynamoDB tables into the Kafka connector.

From this blog post: https://www.singlestore.com/blog/migrating-from-rockset-dynamodb-to-singlestore/

```bash
python3 ~/Documents/projects/2024-demothon-team-hybid-vector/aws/kafka/stream_kafka.py
```

List out Kafka events:

```bash
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

```bash
bin/kafka-console-consumer.sh --topic event_topic --from-beginning --bootstrap-server $BOOTSTRAP_SERVER:9092
```

## Loading to SingleStore

`singlestore_ingestion.sql` provisions tables and pipelines to load into SingleStore.
