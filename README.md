# 🚀 Laboratório: Kafka Connect (JDBC + Debezium CDC) + Postgres → Kafka

Este repositório contém um laboratório simples para **simular** a integração entre um banco **Postgres** e um **Apache Kafka** usando o **Kafka Connect**.  
Você poderá testar duas abordagens:

1. **JDBC Source Connector (incremental)** → captura via polling (`incrementing` ou `timestamp+incrementing`).
2. **Debezium CDC Source Connector** → captura de mudanças em tempo real (CDC) a partir do WAL do Postgres.

---

## 📁 Arquivos incluídos
- `docker-compose.yml` — stack com Zookeeper, Kafka, Postgres, Kafka Connect e Kafka UI.
- `init.sql` — script que cria a tabela `users` e insere dados de exemplo.
- `create-connector-postgres.sh` — script que cria o connector JDBC (incremental).
- `create-connector-debezium.sh` — script que cria o connector Debezium (CDC).
- `plugins/` — diretório onde você deve colocar os conectores (JDBC + Debezium) e drivers.
- `README.md` — este arquivo.

---

## ✅ Pré-requisitos
- Docker (recomendado >= 20.x)
- Docker Compose (v2 ou compatível com `docker-compose.yml` v3.8)
- Conexão de internet para baixar imagens Docker e os conectores (somente na primeira execução)

### Conectores / Drivers necessários (manualmente)
1. **Confluent JDBC Connector** — https://www.confluent.io/hub/confluentinc/kafka-connect-jdbc
2. **Debezium Postgres Connector** — https://www.confluent.io/hub/debezium/debezium-connector-postgresql
3. **PostgreSQL JDBC Driver** (`postgresql-<version>.jar`) — https://jdbc.postgresql.org/download.html

Estrutura típica:

```
./plugins/
  confluentinc-kafka-connect-jdbc/
  debezium-connector-postgresql/
  postgresql-42.5.0.jar
```

---

## ▶️ Passo a passo (execução)

### 1) Preparar o diretório do projeto
Coloque todos os arquivos (`docker-compose.yml`, `init.sql`, scripts de connector) + `plugins/` com os conectores e drivers.

### 2) Tornar os scripts executáveis
```bash
chmod +x create-connector-postgres.sh
chmod +x create-connector-debezium.sh
```

### 3) Subir a stack Docker
```bash
docker-compose up -d
```

Serviços expostos:
- Zookeeper → `localhost:2181`
- Kafka Broker → `localhost:9092`
- Postgres → `localhost:5432` (user: `postgres`, senha: `postgres`, db: `testdb`)
- Kafka Connect REST → `http://localhost:8083`
- Kafka UI → `http://localhost:7070`

### 4) Criar os conectores

#### JDBC (incremental)
```bash
./create-connector-postgres.sh
```

Esse connector fará polling da tabela `users` usando `incrementing.column.name=id`.

#### Debezium (CDC)
Antes de rodar, habilite `wal_level=logical` no Postgres. Isso já está configurado no `docker-compose.yml` deste lab.  
Execute:
```bash
./create-connector-debezium.sh
```

Esse connector vai capturar **inserts, updates e deletes** em tempo real via WAL.

### 5) Verificar no Kafka UI
Abra `http://localhost:7070` → `Topics`.
- Para JDBC: veja `postgres-users`.
- Para Debezium: veja `dbserver1.testdb.users`.

### 6) Testar inserções / updates
```bash
docker exec -it postgres psql -U postgres -d testdb

# Insert
INSERT INTO users (name, email) VALUES ('Charlie', 'charlie@example.com');

# Update
UPDATE users SET email='newcharlie@example.com' WHERE name='Charlie';

# Delete
DELETE FROM users WHERE name='Charlie';
```

No **JDBC**, só inserts aparecem (e apenas após o próximo polling).  
No **Debezium**, inserts/updates/deletes aparecem imediatamente como eventos no Kafka.

---

## ⚙️ Configurações de exemplo

### JDBC Source (incremental)
```json
{
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
}
```

### Debezium CDC (Postgres)
```json
{
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
}
```

---

## 📚 Links úteis
- Confluent Hub — JDBC Connector: https://www.confluent.io/hub/confluentinc/kafka-connect-jdbc
- Debezium PostgreSQL: https://debezium.io/documentation/reference/stable/connectors/postgresql.html
- PostgreSQL JDBC Driver: https://jdbc.postgresql.org/download.html

---

## ✅ Conclusão
Agora você tem duas opções:
- **Polling incremental (JDBC)** → simples para prototipar e ETL batch-like.
- **CDC em tempo real (Debezium)** → captura transações em nível de log, ideal para replicação contínua.

A partir desse laboratório, você pode expandir para Schema Registry, Sinks (Elastic, S3, Redshift, BigQuery), ou mesmo pipelines híbridos.
