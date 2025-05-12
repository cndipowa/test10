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
