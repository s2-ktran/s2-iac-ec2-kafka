import json
import os
from confluent_kafka import Producer, KafkaException, KafkaError
from confluent_kafka.admin import AdminClient, NewTopic
from data.generate_data import main_generation, read_yaml
import time

EC2_PUBLIC_IP = os.environ["EC2_PUBLIC_IP"]

# Initialize Kafka producer
producer = Producer({
    "bootstrap.servers": f"{EC2_PUBLIC_IP}:9092",
    "queue.buffering.max.messages": 1000000,       # Increase the maximum number of messages in the queue
    "queue.buffering.max.kbytes": 1048576,         # Increase the buffer size in KB
    "linger.ms": 50,                               # Add a small delay to batch messages
})
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


def produce_event_logs_to_kafka(num_records, topic_name, dataset_num):
    event_logs = main_generation(num_records, dataset_num)
    for log in event_logs:
        producer.produce(topic_name, value=json.dumps(log))
        producer.poll(0) 
        time.sleep(0.0001)  # Adjust this value as needed
        print(f"Sent: {log}")
    producer.flush(timeout=5)


if __name__ == "__main__":
    file_path = os.getcwd() + "/testing/load_data.yaml"
    if os.path.exists(file_path):
        streaming = read_yaml(file_path)['streaming']
        for stream in streaming:
            num_records = stream["record_count"]
            topic_name = stream["topic_name"]
            dataset_num = stream["dataset"]
            produce_event_logs_to_kafka(num_records,topic_name,dataset_num)
    else:
        continue_loading = "y"
        while continue_loading == "y":
            topic_name = input("What kafka topic would you like to preload? ")
            num_records = int(input("How many entries would you like to create? "))
            # create_kafka_topic(topic_name)
            produce_event_logs_to_kafka(num_records, topic_name, -1)
            continue_loading = input("Would you like to continue loading data (y/n)? ")
