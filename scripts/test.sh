#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"
cd $SCRIPT_DIR/../terraform/

# Set up Python virtual environment and install dependencies
python3 -m venv env
source env/bin/activate
pip install confluent-kafka

# Run your Python script (make sure to adjust the path to your script if needed)
python3 $SCRIPT_DIR/../testing/stream_kafka.py
