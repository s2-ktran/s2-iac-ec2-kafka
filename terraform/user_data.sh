#!/bin/bash
set -x  # Enable debugging
exec > /var/log/user-data.log 2>&1

# Update and install necessary packages
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk  # Install OpenJDK 8

# Download and extract Kafka
wget https://downloads.apache.org/kafka/3.7.1/kafka_2.13-3.7.1.tgz
tar -xzf kafka_2.13-3.7.1.tgz
cd kafka_2.13-3.7.1

# Obtain public IP
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

# Configure Kafka server
sed -i 's|#listeners=PLAINTEXT://:9092|listeners=PLAINTEXT://0.0.0.0:9092|' config/server.properties
sed -i "s|#advertised.listeners=PLAINTEXT://your.host.name:9092|advertised.listeners=PLAINTEXT://$PUBLIC_IP:9092|" config/server.properties

# Start Zookeeper and Kafka in the background
nohup bin/zookeeper-server-start.sh config/zookeeper.properties > zookeeper.log 2>&1 &
sleep 30  # Ensure Zookeeper is up and running

nohup bin/kafka-server-start.sh config/server.properties > kafka.log 2>&1 &
sleep 30  # Ensure Kafka is up and running

# Create Kafka topics
IFS=',' read -ra TOPICS <<< "${KAFKA_TOPICS}"
for TOPIC_INFO in "${TOPICS[@]}"; do
  IFS=':' read -ra TOPIC <<< "$TOPIC_INFO"
  TOPIC_NAME=${TOPIC[0]}
  PARTITIONS=${TOPIC[1]}
  bin/kafka-topics.sh --create --topic "$TOPIC_NAME" --partitions "$PARTITIONS" --replication-factor 1 --bootstrap-server localhost:9092
done