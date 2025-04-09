#!/bin/bash

# Nexus API URL
NEXUS_URL="http://localhost:8081/service/rest"
USER="admin"
PASS="your_admin_password"  # Replace with actual password or fetch from mounted file

echo "Fetching all users..."

users=$(curl -s -u $USER:$PASS "$NEXUS_URL/beta/security/users" | jq -r '.[].userId')

for user in $users; do
  echo "-----------------------------"
  echo "User: $user"

  # Get user details (includes roles)
  user_info=$(curl -s -u $USER:$PASS "$NEXUS_URL/beta/security/users/$user")
  roles=$(echo "$user_info" | jq -r '.roles[]')

  echo "Roles:"
  for role in $roles; do
    echo "  - $role"

    # Get role details to show privileges
    role_info=$(curl -s -u $USER:$PASS "$NEXUS_URL/beta/security/roles/$role")
    privileges=$(echo "$role_info" | jq -r '.privileges[]?')

    if [ -n "$privileges" ]; then
      echo "    Privileges:"
      for priv in $privileges; do
        echo "      * $priv"
      done
    else
      echo "    (No privileges found)"
    fi
  done
done
