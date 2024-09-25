import yaml
import os
import uuid
import random
from datetime import datetime, timedelta, date

# Get the directory where the script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Example: Random date between 2023-01-01 and 2023-12-31
start_date = date(2023, 1, 1)
end_date = date(2023, 12, 31)

def read_yaml(yaml_file_path):
    with open(yaml_file_path, 'r') as file:
        return yaml.safe_load(file)
    
def prompt_options(options):
    print("Please choose from the following options:")
    for i, option in enumerate(options, 1):
        print(f"{i}. {option}")

# Prompt the user to select an option
    while True:
        try:
            choice = int(input("Enter the number corresponding to your choice (eg, 1): "))
            if 1 <= choice <= 3:
                print(f"You chose: {options[choice - 1]}")
                return options[choice - 1]
            else:
                print(f"Invalid input. Please enter a number between 1 and {len(options)}.")
        except ValueError:
            print("Invalid input. Please enter a valid number.")

def random_date(start_date, end_date):
    delta = end_date - start_date
    random_days = random.randint(0, delta.days)
    return str(start_date + timedelta(days=random_days))


def generate_data(data_format, amount):
    event_logs = []
    keys = data_format.keys()
    while len(event_logs) < amount:
        json_value = {}
        for value in keys:
            value_type = data_format[value]["type"]
            if value_type == "uuid":
                json_value[value] = uuid.uuid4().hex
            elif value_type == "timestamp":
                json_value[value] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            elif value_type == "choice":
                json_value[value] = random.choice(list(data_format[value]["values"]))
            elif value_type == "date":
                json_value[value] = random_date(start_date, end_date)
            elif value_type == "int":
                json_value[value] = random.randint(data_format[value]["min"], data_format[value]["max"])
            elif value_type == "JSON":
                json_value[value] = data_format[value]["values"]
            if "prefix" in data_format[value]:
                json_value[value] = data_format[value]["prefix"] + str(json_value[value])
        event_logs.append(json_value)
    return event_logs



def main_generation(num_records, dataset):
    data = read_yaml(os.path.join(script_dir, 'data.yaml'))['data']
    data_types = list(data.keys())
    if dataset == -1:
        choice = prompt_options(data_types)
    else:
        choice = dataset
    data_format = data[choice]
    return generate_data(data_format, num_records)

# Testing purposes
if __name__ == "__main__":
    print(main_generation(10, -1))
