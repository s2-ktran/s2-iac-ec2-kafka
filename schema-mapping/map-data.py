import os
import re
import yaml

sql_file_name = "mysql-schema.sql"
yaml_file_name = "../testing/data/data.yaml"
kafka_topic_file_name = "kafka_topics.txt"
load_data_file_name = "../testing/load_data.yaml"
script_dir = os.path.dirname(os.path.abspath(__file__))
sql_file_path = os.path.join(script_dir, sql_file_name)
yaml_file_path = os.path.join(script_dir, yaml_file_name)
kafka_file_path = os.path.join(script_dir, kafka_topic_file_name)
load_data_file_path = os.path.join(script_dir, load_data_file_name)
RECORD_COUNT = 1000

def topic_config(table_names):
    return [{'name': table + '_topic', 'partitions': 4 } for table in table_names]

# Define a function to extract CREATE TABLE statements
def extract_create_statements(file_path):
    with open(file_path, 'r') as sql_file:
        sql_content = sql_file.read()
    create_table_pattern = r'CREATE TABLE.*?;(?:\s|$)'
    create_statements = re.findall(create_table_pattern, sql_content, re.DOTALL | re.IGNORECASE)
    return create_statements


def write_yaml(input_dict, file_path):
    with open(file_path, 'w') as yaml_file:
        yaml.dump(input_dict, yaml_file, default_flow_style=False)

def generate_attr_def(attr, attr_type):
    definition = {}
    if attr_type.startswith("INT") or attr_type.startswith("DECIMAL") or attr_type.startswith("FLOAT"):
        definition["type"] = "int"
        definition["min"] = 1
        definition["max"] = 100
    elif attr_type.startswith("VARCHAR") or attr_type.startswith("TEXT") or attr_type.startswith("ENUM"):
        definition["type"] = "choice"
        definition["values"] = ["choice 1", "choice 2", "choice 3"]
    elif attr_type.startswith("DATE"):
        definition["type"] = "date"
    elif attr_type.startswith("BOOLEAN"):
        definition["type"] = "int"
        definition["min"] = 0
        definition["max"] = 1
    elif attr_type.startswith("TIMESTAMP") or attr_type.startswith("TIME"):
        definition["type"] = "timestamp"
    else: 
        definition["type"] = attr_type
    return definition

# TODO: Substitution of ' to " and removing initial " with '
def generate_table_names(tables_dict):
    table_names = tables_dict["data"].keys()
    topics = topic_config(table_names)
    with open(kafka_file_path, 'w') as file:
        file.write("\"")
        file.write(str(topics))
        file.write("\"")
    return table_names

def create_streaming_file(table_names):
    streaming_list = []
    for name in table_names:
        streaming_list.append({
            "topic_name": name + "_topic",
            "record_count": RECORD_COUNT,
            "dataset": name,
        })
    write_yaml({"streaming": streaming_list}, load_data_file_path)

def write_tables_dict(create_table_statements):
    tables_dict = {"data": {}}
    for table_statement in create_table_statements:
        table_input = {}
        split_table = table_statement.split("\n")
        name = split_table[0].lower().split(" ")[2]
        for line in split_table[1:-2]:
            words = line.lstrip().split(" ")
            attr = words[0] 
            if attr != "FOREIGN" and attr != "PRIMARY":
                attr_type = words[1]
                table_input[attr] = generate_attr_def(attr, attr_type)
                print(attr, attr_type)
        tables_dict["data"][name] = table_input
        print("")
    write_yaml(tables_dict, yaml_file_path)
    return tables_dict


if __name__ == "__main__":
    create_table_statements = extract_create_statements(sql_file_path)
    tables_dict = write_tables_dict(create_table_statements)
    table_names = generate_table_names(tables_dict)
    create_streaming_file(table_names)


    
