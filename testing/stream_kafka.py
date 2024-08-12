import json
import uuid
import random
import datetime
import os
from confluent_kafka import Producer
from decimal import Decimal

EC2_PUBLIC_IP = os.environ["EC2_PUBLIC_IP"]

# Initialize Kafka producer
producer = Producer({"bootstrap.servers": f"{EC2_PUBLIC_IP}:9092"})


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
    num_records = 10  # Number of event logs to generate
    topic_name = "event_topic"  # Kafka topic to send the logs to
    produce_event_logs_to_kafka(num_records, topic_name)
