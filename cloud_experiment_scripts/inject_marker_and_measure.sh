#!/usr/bin/env bash
# inject_marker_and_measure.sh
AUTH_LOG=${1:-/var/log/auth.log}
WAZUH_API=${2:-http://10.1.3.191:55000}
WAZUH_USER=${3:-user}
WAZUH_PASS=${4:-pass}
marker="TEST_$(hostname)_$(date +%s)_$RANDOM"
echo "$(date +"%b %d %H:%M:%S") $marker: INJECT_TEST" | sudo tee -a "$AUTH_LOG" >/dev/null
t0=$(date +%s%3N)
while true; do
  res=$(curl -s -u "${WAZUH_USER}:${WAZUH_PASS}" "${WAZUH_API}/security/events?limit=50" )
  found=$(echo "$res" | grep -c "$marker" || true)
  if [ "$found" -gt 0 ]; then
    t1=$(date +%s%3N); dt_ms=$((t1 - t0))
    echo "Marker encontrado. Latência ingest (ms): $dt_ms"; exit 0
  fi
  sleep 0.5
  if [ $(( ( $(date +%s%3N) - t0 )/1000 )) -gt 120 ]; then echo "Timeout"; exit 2; fi
done
