#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"

# Change to the parent directory of the script directory
cd "$SCRIPT_DIR/../"

# Set up Python virtual environment and install dependencies
if [ ! -d "env" ]; then
    python3 -m venv env
    source env/bin/activate
    pip install confluent-kafka pyyaml
    echo "'env' directory created and dependencies installed."
else
    echo "'env' directory already exists."
fi

# Activate the virtual environment and run your Python script
source env/bin/activate
python3 "$SCRIPT_DIR/../testing/stream_kafka.py"

