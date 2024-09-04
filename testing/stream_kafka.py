import json
import uuid
import random
import datetime
import os
from confluent_kafka import Producer, KafkaException, KafkaError
from confluent_kafka.admin import AdminClient, NewTopic

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


# Function to generate event logs
def generate_event_logs(num_records):
    event_logs = []
    unique_event_ids = set()

    while len(unique_event_ids) < num_records:
        event_id = f"event_{uuid.uuid4().hex}"
        if event_id not in unique_event_ids:
            unique_event_ids.add(event_id)
            timestamp = datetime.datetime.now().isoformat()
            event_type = random.choice(["accident", "maintenance", "other"])
            description = random.choice(
                [
                    "Minor accident",
                    "Scheduled maintenance",
                    "Unscheduled maintenance",
                    "Other event",
                ]
            )
            related_vehicle_id = f"vehicle_{random.randint(1, 100)}"
            additional_info = {"info": "Additional event details"}

            record = {
                "event_id": event_id,
                "timestamp": timestamp,
                "type": event_type,
                "description": description,
                "related_vehicle_id": related_vehicle_id,
                "additional_info": additional_info,
            }
            event_logs.append(record)

    return event_logs


def produce_event_logs_to_kafka(num_records, topic_name):
    event_logs = generate_event_logs(num_records)

    for log in event_logs:
        producer.produce(topic_name, value=json.dumps(log))
        print(f"Sent: {log}")

    # Wait up to 5 seconds for messages to be sent
    producer.flush(timeout=5)


# Example usage
if __name__ == "__main__":
    num_records = int(ENTRY_COUNT)
    topic_name = KAFKA_TOPIC
    create_kafka_topic(topic_name)
    produce_event_logs_to_kafka(num_records, topic_name)
