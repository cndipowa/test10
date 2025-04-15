Steps to Save the Guide:
For Markdown (.md):

Copy the entire text below.

Paste into a text editor (VS Code, Notepad++, etc.).

Save as nfs_openshift_troubleshooting.md.

For PDF:

Paste the text into a Word/Google Doc.

Use "Save as PDF" from the file menu.

Full NFS Troubleshooting Guide for OpenShift
markdown
Copy
# NFS Troubleshooting Guide for OpenShift

## **1. NFS Server Checks**
### **1.1 Verify NFS Service Status**
```bash
systemctl status nfs-server  # Check if NFS service is running
systemctl status rpcbind     # Verify RPC bind service (required for NFS)
✅ Expected: Both services should be active (running).

1.2 Check NFS Exports
bash
Copy
exportfs -v                  # List all exported directories
cat /etc/exports             # Verify export configurations
✅ Expected:

Correct export path (/path/to/share) with proper permissions (rw,sync,no_root_squash).

Correct client IP/network allowed.

1.3 Test NFS Mount Locally
bash
Copy
mkdir /mnt/test
mount -t nfs <NFS_SERVER_IP>:/export/path /mnt/test  # Test mount
df -h | grep nfs             # Verify mount
umount /mnt/test             # Cleanup
✅ Expected: Mount succeeds without errors.

1.4 Check Firewall Rules
bash
Copy
firewall-cmd --list-all | grep nfs  # Check NFS ports (2049, 111, 20048)
✅ Expected: Ports 2049 (nfs), 111 (rpcbind), and 20048 (mountd) are open.

1.5 Review NFS Server Logs
bash
Copy
journalctl -u nfs-server -f   # Check NFS service logs
tail -f /var/log/messages    # General system logs for NFS errors
🔍 Look for:

Permission denials (access denied).

Connection timeouts.

2. OpenShift (OCP) Checks
2.1 Verify PersistentVolume (PV) & PersistentVolumeClaim (PVC)
bash
Copy
oc get pv                   # Check PV status
oc get pvc -n <namespace>   # Check PVC binding
oc describe pv <pv-name>    # Inspect PV details
✅ Expected:

PV Status = Bound.

PVC shows Bound with correct capacity.

2.2 Check Pod Mount Status
bash
Copy
oc get pods -n <namespace> -o wide  # Verify pod is running
oc describe pod <pod-name> | grep -i mount  # Check mount errors
🔍 Look for:

MountVolume.SetUp failed errors.

Timeouts connecting to NFS.

2.3 Test NFS Mount Inside a Debug Pod
bash
Copy
oc run nfs-test --image=busybox --rm -it -- sh
mount -t nfs <NFS_SERVER>:/export/path /mnt
ls /mnt                      # Check if files are accessible
✅ Expected: Files are readable/writable.

2.4 Check OpenShift Logs
bash
Copy
oc logs <pod-name> -n <namespace>  # Application logs
oc get events -n <namespace>       # Cluster events
🔍 Look for:

FailedMount events.

Permission issues (access denied).

2.5 Verify Node NFS Client Configuration
bash
Copy
oc debug node/<node-name>          # Access node shell
chroot /host
rpcinfo -p <NFS_SERVER_IP>         # Verify RPC services
mount | grep nfs                   # Check existing NFS mounts
✅ Expected:

rpcinfo shows nfs, mountd, nlockmgr.

No stale mounts.

3. Common Fixes
NFS Server:

Restart NFS: systemctl restart nfs-server.

Update /etc/exports and run exportfs -ra.

Adjust firewall: firewall-cmd --add-service=nfs --permanent.

OpenShift:

Recreate PV/PVC if stuck.

Ensure no_root_squash is set if pods need root access.

Check SELinux (setenforce 0 to test).


