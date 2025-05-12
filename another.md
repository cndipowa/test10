# Distributed Tracing in a Service Mesh with OpenTelemetry, Tempo & Grafana

## 1. Introduction

**Objective**: Demonstrate distributed tracing in a service mesh using OpenTelemetry (OTEL), Tempo, and Grafana.

**Components**:

* OpenTelemetry (Java agent, Collector)
* Istio (Service Mesh)
* Grafana Tempo (Trace backend)
* Grafana (Visualization)

---

## 2. Architecture Overview

```
[Java App w/ OTEL Agent] ──► [Istio Sidecar] ──► [OTEL Collector] ──► [Grafana Tempo] ──► [Grafana UI]
                               ▲                          │
                         Service Mesh                 Metrics (optional)
```

---

## 3. Java Application Instrumentation

Use the OTEL Java agent to instrument the app automatically.

```bash
java -javaagent:opentelemetry-javaagent.jar \
     -Dotel.service.name=payment-service \
     -Dotel.exporter.otlp.endpoint=http://otel-collector:4317 \
     -jar app.jar
```

Instrumentations:

* HTTP (RestTemplate, WebClient)
* JDBC, Kafka, gRPC

---

## 4. OTEL Collector

Receives, processes, and exports telemetry data.

**Sample Configuration**:

```yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:

processors:
  batch:

exporters:
  otlp:
    endpoint: tempo:4317
    tls:
      insecure: true

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp]
```

---

## 5. Service Mesh (Istio)

Istio injects sidecars that capture telemetry and can forward to OTEL.

**Telemetry CR Example**:

```yaml
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: enable-tracing
  namespace: default
spec:
  tracing:
    - providers:
        - name: otel
```

---

## 6. Tempo (Trace Backend)

Grafana Tempo stores trace data in a cost-effective, scalable way.

**Supports**:

* OTLP
* Jaeger
* Zipkin

---

## 7. Grafana for Visualization

* Add Tempo as a datasource
* Use **Explore** to query traces
* Dashboards can correlate metrics and traces

---

## 8. Live Demo (Optional)

* Generate traffic: `curl` or load generator
* Show:

  * Trace timeline in Grafana
  * Latency breakdown
  * Multi-service trace spans

---

## 9. Benefits

* End-to-end visibility
* Fast root cause analysis
* Vendor-neutral implementation
* Compatible with other observability tools

---

## 10. Challenges

* Agent tuning and overhead
* High data volume
* Trace/metric/log correlation

---

## 11. Future Enhancements

* Add log correlation
* Add metrics in same pipeline
* Extend across multiple clusters

  ##############################################

  # Distributed Tracing in a Service Mesh with OpenTelemetry, Tempo, and Grafana

## 1. Introduction to Distributed Tracing

* **Problem**: Difficulty observing request flows across microservices.
* **Solution**: Distributed tracing enables visibility, diagnosis, and performance monitoring.
* **OpenTelemetry (OTEL)** is a vendor-neutral specification for collecting telemetry data.

## 2. Why Use Service Mesh + OTEL

* **Service Mesh (e.g., Istio)** manages service-to-service communication.
* OTEL enhances observability by capturing:

  * Infrastructure-level traces (from mesh proxies)
  * Application-level traces (via SDKs or agents)

## 3. High-Level Architecture

```
[Java App] --> [OTEL Agent (Java)] --> [OTEL Collector] --> [Tempo]
                                    \                    \
                                     \--> [Metrics]     \--> [Grafana UI]
```

## 4. Component Details

### OTEL Agent (Java)

* Injected via JVM arg: `-javaagent:/otel-agent/opentelemetry-javaagent.jar`
* Captures HTTP, DB, and internal method traces.
* Configurable via environment variables (OTEL\_EXPORTER\_OTLP\_ENDPOINT, etc).

### OTEL Collector

* **Receives**, **processes**, and **exports** telemetry.
* Example pipeline:

```yaml
receivers:
  otlp:
    protocols:
      grpc:

exporters:
  otlp/tempo:
    endpoint: tempo:4317
    tls:
      insecure: true

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [otlp/tempo]
```

### Tempo

* Trace storage backend by Grafana Labs.
* No need for indexing (simplifies ops).
* Stores to object storage (e.g., S3, GCS, MinIO).

### Grafana

* Queries and visualizes traces from Tempo.
* Rich UI with waterfall views, span details.
* Can correlate with logs and metrics.

## 5. Kubernetes Deployment Model

```
[ K8s Cluster ]
   ├── Java App Pod
   │    └── OTEL Agent (Java)
   ├── Istio Sidecar
   ├── OTEL Collector Deployment
   ├── Tempo Deployment or StatefulSet
   └── Grafana Deployment
```

* Istio handles network traces.
* OTEL Agent enriches with application-level spans.

## 6. Demo Steps

1. Deploy all components in a K8s cluster.
2. Send traffic to the Java app.
3. OTEL Agent emits spans to Collector.
4. Collector exports traces to Tempo.
5. Open Grafana, visualize trace flows.

## 7. Benefits

* Unified observability with OpenTelemetry.
* Seamless integration of app and infra tracing.
* Tempo is scalable and cost-effective.
* Grafana provides deep insights and dashboards.

## 8. Best Practices & Challenges

* Set consistent `service.name` in all emitters.
* Use tail-based sampling in OTEL Collector if needed.
* Secure endpoints and export paths (TLS, auth).
* Monitor OTEL Collector performance.

## 9. Future Enhancements

* Add **logs correlation** using Grafana Loki.
* Link **traces with metrics** using exemplars.
* Explore **Service Graphs** in Grafana.

## 10. References

* [https://opentelemetry.io/](https://opentelemetry.io/)
* [https://grafana.com/oss/tempo/](https://grafana.com/oss/tempo/)
* [https://github.com/open-telemetry/opentelemetry-java-instrumentation](https://github.com/open-telemetry/opentelemetry-java-instrumentation)
* [https://istio.io/latest/docs/tasks/observability/](https://istio.io/latest/docs/tasks/observability/)

