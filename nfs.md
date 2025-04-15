
# NFS Troubleshooting Guide for OpenShift with NFS-Backed Pods

## Overview
This guide outlines steps to troubleshoot issues when OpenShift pods are using NFS volumes provided by NFS servers running on VMs.

---

## Part 1: Checks on NFS Servers (VMs)

### 1. Verify NFS Server is Running
```bash
systemctl status nfs-server
```
- **Expected**: Active (running)

### 2. Check NFS Export Configuration
```bash
cat /etc/exports
```
- **Expected**: Directories are exported with correct access permissions and IP ranges.

### 3. Check Exported File Systems
```bash
exportfs -v
```
- **Expected**: Shows exported directories with client access settings.

### 4. Check NFS Port Bindings
```bash
rpcinfo -p | grep nfs
```
- **Expected**: NFS and mountd ports are visible.

### 5. Firewall and SELinux
```bash
sudo firewall-cmd --list-all
getenforce
```
- **Expected**: NFS ports open (2049), SELinux in `permissive` or policies configured correctly.

### 6. Inspect NFS Server Logs
```bash
journalctl -u nfs-server
tail -f /var/log/messages
```

---

## Part 2: Checks on OpenShift

### 1. Check Pod Events for Errors
```bash
oc get events -n <namespace>
oc describe pod <pod-name> -n <namespace>
```
- **Expected**: No mount errors or timeouts.

### 2. Check PVC and PV Binding
```bash
oc get pvc -n <namespace>
oc describe pvc <pvc-name> -n <namespace>
oc get pv
```
- **Expected**: PVCs are `Bound` to PVs.

### 3. Validate PV NFS Configuration
```bash
oc get pv <pv-name> -o yaml
```
- **Expected**: Correct NFS server and path in the spec.

### 4. Test Mount from Pod
Run a debug pod or use an existing pod with `nfs-utils`:
```bash
oc debug pod/<pod-name> -n <namespace> --image=registry.access.redhat.com/ubi8/ubi
yum install -y nfs-utils
mount -t nfs <nfs-server-ip>:/export/path /mnt
```
- **Expected**: Mount succeeds, no errors.

### 5. Check OpenShift Node Logs (Where Pod is Scheduled)
```bash
oc adm node-logs <node-name> --path=journal
journalctl | grep nfs
```

### 6. Confirm Node Can Reach NFS Server
```bash
ping <nfs-server-ip>
telnet <nfs-server-ip> 2049
```

---

## Notes
- Always ensure time synchronization between OpenShift nodes and NFS servers.
- If using SELinux and FPolicy, label volumes correctly with `chcon` or `semanage fcontext`.
- If persistent issues, consider inspecting `kubelet` logs on the nodes.

