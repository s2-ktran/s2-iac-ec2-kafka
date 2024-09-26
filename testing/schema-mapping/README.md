# Creating Sample Data from MySQL Syntax

## MySQL Schema

Input sample tables into the `testing/schema-mapping/ex-mysql-schema.sql` file.

## Generate data and testing vars

Run the following script.

```bash
python testing/schema-mapping/map-data.py
```

Generates:

- `testing/schema-mapping/kafka_topics.txt`: topics for provisioning deployment
- `testing/testing_var.yaml`: script for automatically loading topics using `testing/stream_kafka.py`
