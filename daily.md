✅ Daily Manual System Checks Checklist
1. OpenShift Cluster Health
 oc get nodes — All nodes are Ready

 oc get pods -A — No pods stuck in CrashLoopBackOff, Error, or Pending

 oc get clusterversion — No ongoing failed updates

 oc get co — All cluster operators are Available, Healthy

 Monitor resource usage (CPU, memory, disk) for critical namespaces

 Check events for anomalies: oc get events -A --sort-by='.lastTimestamp'

2. OpenShift Storage & Volume Checks
 Check PVCs: oc get pvc -A — All bound, none in Lost or Pending

 Ensure NFS or other dynamic provisioners are operational

3. VMware (vSphere/ESXi)
 Verify ESXi host health in vCenter (CPU, RAM, disk utilization)

 Check for any alerts or alarms in vSphere

 Confirm VM backup jobs completed successfully (if applicable)

 Spot-check VM power state for critical VMs (e.g., OpenShift nodes)

4. Nexus Repository
 Log in to the UI — confirm it's accessible

 Check disk space on the Nexus host

 Look for storage blobs growth and cleanup issues

 Check system.log and request.log for errors or slow requests

 Verify critical proxy or hosted repos are online

5. GitLab
 Access web UI and check GitLab Services Health (Admin Area > Monitoring)

 gitlab-rake gitlab:check if SSH access is available

 Check background jobs (Sidekiq queue length)

 Ensure CI/CD pipelines are not stuck or failing across multiple repos

 Monitor repo storage usage and availability

6. Elasticsearch / Logging
 Verify OpenSearch/Elasticsearch cluster health: _cluster/health

 Confirm no shards are unassigned or in red status

 Check disk utilization per node (hot nodes in particular)

 Review logs for ingestion delays or indexing errors

 Ensure Kibana or log UI is accessible

7. Network & Ingress
 Check ingress controllers: oc get pods -n openshift-ingress

 Verify DNS resolution for internal/external services

 Use curl or synthetic checks to verify critical endpoints are responding

8. Security & Access
 Review failed login attempts (GitLab, Nexus, OpenShift, etc.)

 Spot-check RBAC changes or permission escalations

 Confirm key secrets and certificates (TLS) are not near expiration

9. Backup & Monitoring Systems
 Verify that daily backups ran (for GitLab, Nexus, VM snapshots, etc.)

 Confirm Prometheus/Grafana dashboards show expected metrics

 Review overnight alerts in alerting systems (e.g., Alertmanager, Opsgenie)

10. Ticketing System or ITSM Queue
 Review new or open incident and service request tickets

 Check for recurring issues reported by users (especially login, performance)

Optional Automation Suggestion
Many of these checks can be automated using:

OpenShift CronJobs or Ansible playbooks

Prometheus/Alertmanager for monitoring

Custom dashboards and health checks via Grafana

CI jobs to validate service endpoints (e.g., GitLab CI or Jenkins)
