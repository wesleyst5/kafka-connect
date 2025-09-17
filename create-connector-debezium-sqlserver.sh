#!/bin/bash

# Script para criar o connector Debezium SQL Server → Kafka

CONNECT_URL="http://localhost:8084/connectors"

echo "🔌 Criando connector Debezium para SQL Server..."

curl -s -X POST -H "Content-Type: application/json" \
  --data '{
    "name": "debezium-sqlserver-connector",
    "config": {
      "connector.class": "io.debezium.connector.sqlserver.SqlServerConnector",
      "tasks.max": "1",
      "database.hostname": "sqlserver",
      "database.port": "1433",
      "database.user": "sa",
      "database.password": "yourStrong(!)Password",
      "database.names": "testdb",
      "database.encrypt": "false",
      "database.history.kafka.bootstrap.servers": "kafka:29092",
      "database.history.kafka.topic": "schema-changes.sqlserver",

      "topic.prefix": "sqlservercdc",
      "table.include.list": "dbo.users,dbo.orders,dbo.products",

      "snapshot.mode": "initial",
      "poll.interval.ms": "1000"
    }
  }' \
  $CONNECT_URL | jq .

echo "✅ Connector Debezium SQL Server criado (verifique no Kafka UI ou via REST API)."