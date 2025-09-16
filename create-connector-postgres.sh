#!/bin/bash

echo "⏳ Aguardando o Kafka Connect subir..."
sleep 20  # tempo para os serviços inicializarem

echo "🚀 Criando connector JDBC Source (Postgres -> Kafka)..."

curl -s -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "postgres-source-connector",
    "config": {
      "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
      "connection.url": "jdbc:postgresql://postgres:5432/testdb",
      "connection.user": "postgres",
      "connection.password": "postgres",
      "table.whitelist": "users",
      "mode": "incrementing",
      "incrementing.column.name": "id",
      "topic.prefix": "postgres-",
      "poll.interval.ms": 5000
    }
  }'

echo -e "\n✅ Connector criado! Verifique no Kafka UI (http://localhost:7070)."
