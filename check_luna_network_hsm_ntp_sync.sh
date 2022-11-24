#!/bin/bash
#
# hablutzel1@gmail.com
# Checks the NTP synchronization status of a Thales Luna Network HSM or Luna SA.
# It should be called like this:
# check_luna_network_hsm_ntp_sync.sh hsm1.example.org monitor
# Where 'monitor' is a LunaSH user that uses SSH public key authentication.

HOST="$1"
USER="$2"

if output=$(ssh -n "$USER"@"$HOST" 'sysconf ntp status' | grep -E "^\*"); then
  if [[ "$output" =~ \*LOCAL(0)* ]]; then
    echo "No synchronization with the time server (only local synchronization?)"
    # TODO or should we just WARN or even provide an OK? Understand what exactly does it mean for an entry to start with "*LOCAL(0)".
    exit 2;
  else
    peer="$(echo "$output" | awk '{print $1}' | cut -d "*" -f 2)"
    offset="$(echo "$output" | awk '{print $9}')"
    echo "Synchronized with the server: $peer offset: $offset"
    exit 0
  fi
else
  echo "No synchronization with the time server"
  exit 2
fi
