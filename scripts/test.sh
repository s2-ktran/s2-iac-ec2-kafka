#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"

# Set up Python virtual environment and install dependencies
python -m venv env
source env/bin/activate
pip install confluent-kafka

# Run your Python script (make sure to adjust the path to your script if needed)
read -p "What name would you like for your kafka topic: " KAFKA_TOPIC
read -p "How many entries would you like to create: " ENTRY_COUNT

export ENTRY_COUNT=$ENTRY_COUNT
export KAFKA_TOPIC=$KAFKA_TOPIC
python3 $SCRIPT_DIR/../testing/stream_kafka.py
