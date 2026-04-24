---
name: kafka
description: Kafka operations using kafkacmd and kcat CLI tools. Use when consuming messages, managing consumer groups, describing topics, resetting offsets, or inspecting Kafka cluster state. Covers kafkacmd wrapper, kcat via Docker (confluentinc), Avro deserialization, timestamp-based offsets with to_ts/from_ts, and jq post-processing. Trigger phrases include 'consume from kafka', 'reset offsets', 'describe topic', 'consumer group', 'kcat', 'kafkacmd'.
---
# Kafka CLI Operations
## Configuration Files
Two separate config formats in `~/.kafka/`:
| Tool | File pattern | Format |
|------|-------------|--------|
| kafkacmd | `{env}.config` | Java properties (kafka-* native) |
| kcat | `{env}.kcat` | librdkafka key=value |
Environments: `dev`, `qa`, `prod`, `qa.international`, `playground`, `docker`
---
## kafkacmd
Wraps `kafka-*` commands with environment-aware config. Located at `app/scripts/kafkacmd.sh`. Always use `--docker` (runs in `confluentinc/cp-kafka:7.4.3`).
```
kafkacmd --docker <environment> <command> [options...]
```
### Consumer Groups
```bash
# Describe all groups
kafkacmd --docker prod consumer-groups --timeout 60000 --describe --all-groups
# Describe specific group
kafkacmd --docker prod consumer-groups --timeout 60000 --describe --group my-service.consumer-group
# List groups
kafkacmd --docker prod consumer-groups --list
# Reset offsets to datetime (MUST stop consumers first)
kafkacmd --docker prod consumer-groups \
  --group my-service.consumer-group \
  --reset-offsets --to-datetime "2026-02-01T13:00:00.000" \
  --all-topics --execute
# Reset offsets to earliest for a specific topic
kafkacmd --docker qa.international consumer-groups \
  --timeout 60000 \
  --group my-service.consumer-group \
  --reset-offsets --to-earliest \
  --topic my.topic.name \
  --execute
```
### Topics & Configs
```bash
kafkacmd --docker prod topics --list
kafkacmd --docker prod topics --describe --topic buyer.user.profile
# Topic configuration
kafkacmd --docker prod configs --describe --entity-type topics --entity-name vendor.users.v2 --all
# Broker configuration
kafkacmd --docker prod configs --entity-type brokers --entity-default --describe
```
---
## kcat
Runs via Docker (`confluentinc/cp-kcat:7.5.0`). Config paths remap to `/tmp/.kafka/` inside the container.
```
docker run --rm -t -i -v ~/.kafka:/tmp/.kafka confluentinc/cp-kcat:7.5.0 \
  -C -F /tmp/.kafka/{env}.kcat -t <topic> [options]
```
### Key Options
| Option | Description |
|--------|-------------|
| `-s value=avro` | Avro deserialize values |
| `-s key=avro` | Avro deserialize keys |
| `-e` | Exit at end of topic (EOF) |
| `-J` | JSON envelope (partition, offset, timestamp, headers) |
| `-c <N>` | Consume N messages |
| `-o <offset>` | Start offset (see below) |
| `-p <partition>` | Specific partition |
| `-f '<fmt>'` | Custom format (`%p` partition, `%k` key, `%s` value, `%T` timestamp) |
### Offset Options (`-o`)
| Value | Description |
|-------|-------------|
| `beginning` | From start |
| `end` | Tail new messages only |
| `-N` | Last N messages (e.g. `-o -50`) |
| `<number>` | Specific offset (e.g. `-o 1027`) |
| `s@<epoch_ms>` | From timestamp: `-o s@$(to_ts "2025-04-01T00:00:00Z")` |
---
## to_ts / from_ts
Shell functions (`.zshrc`) for ISO-8601 <-> Unix epoch. Requires `gdate` (Homebrew coreutils).
```bash
to_ts "2025-04-01T00:00:00Z"       # -> 1743465600000 (ms, default)
to_ts "2025-04-01T00:00:00Z" s     # -> 1743465600 (seconds)
from_ts 1743465600000               # -> 2025-04-01T00:00:00 (ms, default)
from_ts 1743465600 s                # -> 2025-04-01T00:00:00 (seconds)
```
---
## Recipes
### Time-Based Consumption with to_ts
```bash
# From specific date with JSON envelope
docker run --rm -t -i -v ~/.kafka:/tmp/.kafka confluentinc/cp-kcat:7.5.0 \
  -C -F /tmp/.kafka/prod.kcat -t catalog.providers -J -e \
  -o s@$(to_ts "2025-08-26T00:00:00Z")
# With Avro deserialization + jq
docker run --rm -t -i -v ~/.kafka:/tmp/.kafka confluentinc/cp-kcat:7.5.0 \
  -C -F /tmp/.kafka/prod.kcat -t buyer.urls.products -e \
  -o s@$(to_ts "2025-04-01T00:00:00Z") -s value=avro | jq
```
### Specific Partition + Offset
```bash
# Single message at exact partition/offset with JSON envelope
docker run --rm -t -i -v ~/.kafka:/tmp/.kafka confluentinc/cp-kcat:7.5.0 \
  -C -F /tmp/.kafka/prod.kcat -t review.text-reviews.v2 \
  -s value=avro -e -J -o 1027 -p 5 -c 1 | jq
# Avro key + Avro value
docker run --rm -t -i -v ~/.kafka:/tmp/.kafka confluentinc/cp-kcat:7.5.0 \
  -C -F /tmp/.kafka/prod.kcat -t review.text-reviews.v2 \
  -s key=avro -s value=avro -e -o 13431328 -p 2 -c 1 | jq
```
### JSON Envelope Metadata Extraction
```bash
docker run --rm -t -i -v ~/.kafka:/tmp/.kafka confluentinc/cp-kcat:7.5.0 \
  -C -F /tmp/.kafka/prod.kcat -t review.text-reviews.v2 \
  -s value=avro -e -J -o 1027 -p 5 -c 1 \
  | jq '{topic, partition, offset, value_schema_id}'
```
### Parse Stringified JSON Payload
```bash
docker run --rm -t -i -v ~/.kafka:/tmp/.kafka confluentinc/cp-kcat:7.5.0 \
  -C -F /tmp/.kafka/prod.kcat -t catalog.categories -J -e \
  -o s@$(to_ts "2025-11-01T00:00:00Z") -c 1 \
  | jq ".payload | fromjson"
```
### Extract to CSV with jq
```bash
docker run --rm -t -i -v ~/.kafka:/tmp/.kafka confluentinc/cp-kcat:7.5.0 \
  -C -F /tmp/.kafka/prod.kcat -t catalog.software.products -e -s value=avro \
  | jq -r '.featureIds[] as $fid | [.productId, $fid] | @csv' > features.csv
docker run --rm -t -i -v ~/.kafka:/tmp/.kafka confluentinc/cp-kcat:7.5.0 \
  -C -F /tmp/.kafka/prod.kcat -t catalog.software.categories -e -s value=avro \
  | jq -r '. as $cat | .features[] | select(.isTop == true) | [$cat.categoryId, .featureId] | @csv'
```
### Filter + Extract from JSON Envelope
```bash
docker run --rm -t -i -v ~/.kafka:/tmp/.kafka confluentinc/cp-kcat:7.5.0 \
  -C -F /tmp/.kafka/prod.kcat -t catalog.providers -J -e \
  -o s@$(to_ts "2025-08-26T00:00:00Z") \
  | jq -r 'select(.payload | fromjson | .entityDetail.location.longitude == null) | .payload | fromjson | .entityDetail.id'
```
### Custom Format Strings
```bash
docker run --rm -t -i -v ~/.kafka:/tmp/.kafka confluentinc/cp-kcat:7.5.0 \
  -C -F /tmp/.kafka/prod.kcat -t my.topic -s value=avro \
  -f 'Key: %k -- Value: %s\n'
docker run --rm -t -i -v ~/.kafka:/tmp/.kafka confluentinc/cp-kcat:7.5.0 \
  -u -C -F /tmp/.kafka/dev.kcat -t buyer.user.profile -e -s value=avro \
  -f '{"partition":%p,"key":"%k","timestamp":%T,"content":%s}\n'
```
### Docker Compose (Local Development)
```bash
docker compose run kcat -t review.snippets -s value=avro -J
docker compose run kcat -t review.snippets -s value=avro -o end -J
```
### Broker Metadata
```bash
docker run --rm -t -i -v ~/.kafka:/tmp/.kafka confluentinc/cp-kcat:7.5.0 \
  -C -F /tmp/.kafka/prod.kcat -L
```
---
## Quick Decision Guide
| Need | Tool |
|------|------|
| Consumer groups (describe, reset offsets) | kafkacmd |
| List/describe topics and configs | kafkacmd |
| Consume and inspect messages | kcat |
| Consume from specific timestamp | kcat + `to_ts` |
| JSON structured output with metadata | kcat `-J` |
| Local Kafka dev cluster | `docker compose run kcat` |