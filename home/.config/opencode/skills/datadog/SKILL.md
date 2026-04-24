---
name: datadog
description: Query Datadog metrics using pup CLI. Use when analyzing application performance, infrastructure health, or investigating incidents. Covers query syntax, aggregations, tags, jq processing, and common metric patterns.
---
# Datadog Metrics with pup CLI
This skill provides guidance for querying Datadog metrics using the `pup` CLI tool.
## When to Use This Skill
Use this skill when:
- Querying application or infrastructure metrics
- Investigating performance issues or incidents
- Analyzing time-series data from Datadog
- Building metric queries with proper syntax
## Basic Query Syntax
```bash
pup metrics query \
  --query "<aggregation>:<metric_name>{<tags>}" \
  --from "YYYY-MM-DDTHH:MM:SSZ" \
  --to "YYYY-MM-DDTHH:MM:SSZ"
```
### Components
| Component | Description | Example |
|-----------|-------------|---------|
| `aggregation` | How to combine values | `avg`, `sum`, `max`, `min` |
| `metric_name` | The metric identifier | `system.cpu.user`, `http.request.duration` |
| `tags` | Filter criteria | `{env:prod,service:api}` |
| `--from/--to` | Time range (ISO 8601 UTC) | `2026-02-17T06:00:00Z` |
---
## Aggregation Functions
| Function | Use Case |
|----------|----------|
| `avg` | Average value across sources (latency, utilization) |
| `sum` | Total across sources (request counts, bytes) |
| `max` | Peak value (max CPU, max latency) |
| `min` | Minimum value (available capacity) |
### Space Aggregation (across tags)
```bash
# Average CPU across all hosts
avg:system.cpu.user{env:prod}
# Sum of requests across all services
sum:http.requests.count{env:prod}
# Max latency across all endpoints
max:http.request.duration.95percentile{env:prod}
```
### Group By (split by tag)
```bash
# CPU per host
avg:system.cpu.user{env:prod} by {host}
# Requests per service
sum:http.requests.count{env:prod} by {service}
# Latency per endpoint and status
avg:http.request.duration{env:prod} by {endpoint,status}
```
---
## Tag Syntax
### Basic Tags
```bash
# Single tag
{env:prod}
# Multiple tags (AND)
{env:prod,service:api}
# Wildcard
{service:api-*}
# Negation
{env:prod,!service:internal}
```
### Common Tag Patterns
| Tag | Description |
|-----|-------------|
| `env` | Environment (prod, staging, dev) |
| `service` | Service/application name |
| `host` | Hostname |
| `kube_cluster_name` | Kubernetes cluster |
| `kube_namespace` | Kubernetes namespace |
| `kube_deployment` | Kubernetes deployment |
| `pod_name` | Kubernetes pod |
---
## Rate and Count Modifiers
### For Counter Metrics
Counter metrics (cumulative values) need modifiers:
```bash
# Per-second rate
sum:http.requests.count{env:prod}.as_rate()
# Raw count delta between points
sum:http.requests.count{env:prod}.as_count()
```
### When to Use
| Modifier | Use When |
|----------|----------|
| `.as_rate()` | You want "X per second" |
| `.as_count()` | You want total count in time window |
| (none) | Metric is already a gauge (current value) |
---
## Output Processing with jq
### Check if Metric Exists
```bash
pup metrics query --query "..." | jq '.data.data.attributes | {series_count: (.series | length)}'
```
### Extract Time Series with Timestamps
```bash
pup metrics query --query "..." | jq -c '
  [.data.data.attributes.times, .data.data.attributes.values[0]] 
  | transpose 
  | .[] 
  | {time: (.[0]/1000 | strftime("%H:%M:%S")), value: .[1]}'
```
### Extract with Full Date
```bash
pup metrics query --query "..." | jq -c '
  [.data.data.attributes.times, .data.data.attributes.values[0]] 
  | transpose 
  | .[] 
  | {time: (.[0]/1000 | strftime("%Y-%m-%d %H:%M:%S")), value: .[1]}'
```
### Filter Non-Zero Values
```bash
pup metrics query --query "..." | jq -c '
  [.data.data.attributes.times, .data.data.attributes.values[0]] 
  | transpose 
  | .[] 
  | select(.[1] > 0) 
  | {time: (.[0]/1000 | strftime("%H:%M:%S")), value: .[1]}'
```
### Get Group Tags (for by {} queries)
```bash
pup metrics query --query "... by {service}" | jq '.data.data.attributes.series[].group_tags'
```
### Extract Multiple Series
```bash
pup metrics query --query "... by {status}" | jq -r '
  .data.data.attributes as $attr |
  range($attr.series | length) as $i |
  {
    tags: $attr.series[$i].group_tags,
    values: [$attr.times, $attr.values[$i]] | transpose | map({time: (.[0]/1000 | strftime("%H:%M:%S")), value: .[1]})
  }'
```
---
## Common Metric Patterns
### System Metrics
```bash
# CPU usage
avg:system.cpu.user{host:myhost}
avg:system.cpu.system{host:myhost}
# Memory
avg:system.mem.used{host:myhost}
avg:system.mem.free{host:myhost}
# Disk
avg:system.disk.used{host:myhost,device:/dev/sda1}
avg:system.disk.in_use{host:myhost}
# Network
sum:system.net.bytes_rcvd{host:myhost}.as_rate()
sum:system.net.bytes_sent{host:myhost}.as_rate()
```
### Container/Kubernetes Metrics
```bash
# Container CPU
avg:container.cpu.usage{kube_namespace:myns}
avg:kubernetes.cpu.usage.total{kube_namespace:myns}
# Container Memory
avg:container.memory.usage{kube_namespace:myns}
avg:kubernetes.memory.usage{kube_namespace:myns}
# Pod count
sum:kubernetes.pods.running{kube_namespace:myns}
```
### HTTP/Application Metrics
```bash
# Request latency (percentiles)
avg:http.request.duration.95percentile{service:api}
avg:http.request.duration.median{service:api}
# Request count/rate
sum:http.request.count{service:api}.as_rate()
sum:http.request.count{service:api} by {status}.as_rate()
# Error rate
sum:http.request.count{service:api,status:5*}.as_rate()
```
### Database Metrics
```bash
# Connection pool
avg:db.pool.connections.active{service:api}
avg:db.pool.connections.idle{service:api}
avg:db.pool.queue_time.95percentile{service:api}
# Query performance
avg:db.query.duration.95percentile{service:api}
sum:db.query.count{service:api}.as_rate()
```
### Elasticsearch Metrics
```bash
# Cluster health
avg:elasticsearch.cluster.status{cluster_name:mycluster}
avg:elasticsearch.number_of_nodes{cluster_name:mycluster}
# Thread pools
avg:elasticsearch.thread_pool.search.active{cluster_name:mycluster}
avg:elasticsearch.thread_pool.search.queue{cluster_name:mycluster}
avg:elasticsearch.thread_pool.search.rejected{cluster_name:mycluster}.as_count()
# JVM
avg:elasticsearch.jvm.mem.heap_used{cluster_name:mycluster}
avg:elasticsearch.jvm.gc.collection_time{cluster_name:mycluster}.as_rate()
```
---
## Time Range Examples
### Relative (from now)
Note: pup CLI requires absolute timestamps, but here are common ranges to calculate:
| Range | From | To |
|-------|------|-----|
| Last hour | now - 1h | now |
| Last 6 hours | now - 6h | now |
| Last 24 hours | now - 24h | now |
| Last 7 days | now - 7d | now |
### Specific Incident Window
```bash
# 2-hour window around incident
--from "2026-02-17T06:00:00Z" --to "2026-02-17T08:00:00Z"
```
### Business Hours
```bash
# 9 AM to 5 PM UTC
--from "2026-02-17T09:00:00Z" --to "2026-02-17T17:00:00Z"
```
---
## Troubleshooting
### No Data Returned
1. **Check series count:**
   ```bash
   | jq '.data.data.attributes | {series: (.series | length), times: (.times | length)}'
   ```
2. **Verify tags exist:** Try with broader tags or wildcards
   ```bash
   # Too specific
   {env:prod,service:api,version:1.2.3}
   
   # Broader
   {env:prod,service:api}
   ```
3. **Check time range:** Ensure data exists in the specified window
### Metric Not Found
1. Check metric name spelling (case-sensitive)
2. Verify metric is being collected in the environment
3. Try searching for similar metrics:
   ```bash
   # List metrics matching pattern (if available)
   pup metrics search --query "http.request"
   ```
### Empty Values (nulls)
Some time points may have no data. Filter them:
```bash
| jq -c '... | select(.[1] != null) | ...'
```
### Rate Metrics Showing Huge Numbers
You might be looking at a counter without `.as_rate()`:
```bash
# Wrong: shows cumulative total
sum:http.requests.count{env:prod}
# Right: shows per-second rate
sum:http.requests.count{env:prod}.as_rate()
```
---
## Query Building Workflow
1. **Start broad:** Use minimal tags to verify data exists
2. **Add filters:** Narrow down with additional tags
3. **Choose aggregation:** Pick appropriate function for your use case
4. **Add grouping:** Use `by {tag}` to split by dimensions
5. **Apply modifiers:** Add `.as_rate()` or `.as_count()` for counters
6. **Process output:** Use jq to extract readable data
### Example Evolution
```bash
# 1. Does the metric exist?
pup metrics query --query "avg:http.request.duration{*}" ...
# 2. Filter to production
pup metrics query --query "avg:http.request.duration{env:prod}" ...
# 3. Get 95th percentile
pup metrics query --query "avg:http.request.duration.95percentile{env:prod}" ...
# 4. Split by service
pup metrics query --query "avg:http.request.duration.95percentile{env:prod} by {service}" ...
# 5. Format output
pup metrics query --query "..." | jq -c '[...] | ...'
```