#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"

# Set up Python virtual environment and install dependencies
python -m venv env
source env/bin/activate
pip install confluent-kafka

# Run your Python script (make sure to adjust the path to your script if needed)
python3 $SCRIPT_DIR/../testing/stream_kafka.py
