#!/bin/bash
now=$(date +%s)
threshold=$((now + 30*24*60*60)) # 30 days from now

oc get secrets --all-namespaces -o json | jq -r '
  .items[] 
  | select(.type == "kubernetes.io/tls")
  | {
      ns: .metadata.namespace,
      name: .metadata.name,
      cert: .data["tls.crt"]
    } 
  | select(.cert != null)
  | "\(.ns) \(.name) \(.cert)"
' | while read ns name cert_b64; do
  cert=$(echo "$cert_b64" | base64 -d 2>/dev/null)
  if [ -n "$cert" ]; then
    end_date=$(echo "$cert" | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    if [ -n "$end_date" ]; then
      end_ts=$(date -d "$end_date" +%s)
      if [ "$end_ts" -lt "$threshold" ]; then
        echo "$ns/$name: expires on $end_date"
      fi
    fi
  fi
done
