# user_data.sh
#!/bin/bash
sudo yum update -y
sudo dnf install -y java-21-amazon-corretto

wget https://downloads.apache.org/kafka/3.7.1/kafka_2.13-3.7.1.tgz
tar -xzf kafka_2.13-3.7.1.tgz
cd kafka_2.13-3.7.1

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

sed -i 's|#listeners=PLAINTEXT://:9092|listeners=PLAINTEXT://0.0.0.0:9092|' config/server.properties
sed -i "s|#advertised.listeners=PLAINTEXT://your.host.name:9092|advertised.listeners=PLAINTEXT://$PUBLIC_IP:9092|" config/server.properties

nohup bin/zookeeper-server-start.sh config/zookeeper.properties > zookeeper.log 2>&1 &
sleep 30  # Ensure Zookeeper is up and running

nohup bin/kafka-server-start.sh config/server.properties > kafka.log 2>&1 &
sleep 30  # Ensure Kafka is up and running

bin/kafka-topics.sh --create --topic event_topic --bootstrap-server $PUBLIC_IP:9092 --partitions 8
