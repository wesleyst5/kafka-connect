#!/bin/bash

# Script para criar o connector Debezium Postgres → Kafka

CONNECT_URL="http://localhost:8084/connectors"

echo "🔌 Criando connector Debezium para Postgres..."

curl -s -X POST -H "Content-Type: application/json" \
  --data '{
    "name": "debezium-postgres-connector",
    "config": {
      "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
      "plugin.name": "pgoutput",
      "tasks.max": "1",
      "database.hostname": "postgres",
      "database.port": "5432",
      "database.user": "postgres",
      "database.password": "postgres",
      "database.dbname": "testdb",
      "topic.prefix": "debezium",
      "slot.name": "debezium_slot_users",
      "publication.autocreate.mode": "filtered",
      "table.include.list": "public.users"
    }
  }' \
  $CONNECT_URL | jq .

echo "✅ Connector Debezium criado (verifique no Kafka UI ou via REST API)."