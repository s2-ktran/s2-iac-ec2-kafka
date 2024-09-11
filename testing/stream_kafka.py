import json
import os
from confluent_kafka import Producer, KafkaException, KafkaError
from confluent_kafka.admin import AdminClient, NewTopic
from data.generate_data import main_generation

EC2_PUBLIC_IP = os.environ["EC2_PUBLIC_IP"]
KAFKA_TOPIC = os.environ["KAFKA_TOPIC"]
ENTRY_COUNT = os.environ["ENTRY_COUNT"]


# Initialize Kafka producer
producer = Producer({"bootstrap.servers": f"{EC2_PUBLIC_IP}:9092"})
admin_client = AdminClient({"bootstrap.servers": f"{EC2_PUBLIC_IP}:9092"})


# Function to create Kafka topic if it doesn't exist
def create_kafka_topic(topic_name, num_partitions=1, replication_factor=1):
    topic_list = [NewTopic(topic_name, num_partitions, replication_factor)]
    fs = admin_client.create_topics(topic_list)

    for topic, f in fs.items():
        try:
            f.result()  # The result itself is None
            print(f"Topic '{topic_name}' created successfully.")
        except KafkaException as e:
            if e.args[0].code() == KafkaError.TOPIC_ALREADY_EXISTS:
                print(f"Topic '{topic_name}' already exists.")
            else:
                print(f"Failed to create topic '{topic_name}': {e}")
                raise


def produce_event_logs_to_kafka(num_records, topic_name):
    event_logs = main_generation(num_records)

    for log in event_logs:
        producer.produce(topic_name, value=json.dumps(log))
        print(f"Sent: {log}")

    # Wait up to 5 seconds for messages to be sent
    producer.flush(timeout=5)


# Example usage
if __name__ == "__main__":
    num_records = int(ENTRY_COUNT)
    topic_name = KAFKA_TOPIC
    # create_kafka_topic(topic_name)
    produce_event_logs_to_kafka(num_records, topic_name)
