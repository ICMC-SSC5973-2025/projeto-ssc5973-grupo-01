#!/usr/bin/env bash
# collect_metrics.sh
# Usage: ./collect_metrics.sh <output_csv> <interval_seconds> <duration_seconds> [role]
set -euo pipefail
OUT=${1:-metrics.csv}
INTERVAL=${2:-1}
DURATION=${3:-600}
ROLE=${4:-vm}
END=$((SECONDS + DURATION))
echo "run_id,F1_Ataque,F2_Recursos_VM1,F3_Coleta_Logs,timestamp,cpu_vm1,ram_vm1,io_vm1,cpu_vm2,ram_vm2,io_vm2,latencia_ingest_s,eventos_s" > "$OUT"
run_id=${RUN_ID:-1}; F1=${F1:-Unknown}; F2=${F2:-Unknown}; F3=${F3:-Unknown}
while [ $SECONDS -lt $END ]; do
  ts=$(date +"%Y-%m-%dT%H:%M:%S%z")
  cpu_host=$(top -bn1 | awk '/Cpu/ {print 100 - $8}')
  ram_used=$(free | awk '/Mem/ {printf("%.2f", $3/$2*100)}')
  io_write=$(iostat -d 1 2 | awk 'NR>6{print $4; exit}' 2>/dev/null || echo "0")
  cpu_vm1=0; ram_vm1=0; io_vm1=0; cpu_vm2=0; ram_vm2=0; io_vm2=0
  if [ "$ROLE" = "vm1" ]; then
    cpu_vm1=$cpu_host; ram_vm1=$ram_used; io_vm1=$io_write
  elif [ "$ROLE" = "vm2" ]; then
    cpu_vm2=$cpu_host; ram_vm2=$ram_used; io_vm2=$io_write
  else
    cpu_vm1=$cpu_host; ram_vm1=$ram_used; io_vm1=$io_write; cpu_vm2=$cpu_host; ram_vm2=$ram_used; io_vm2=$io_write
  fi
  echo "${run_id},${F1},${F2},${F3},${ts},${cpu_vm1},${ram_vm1},${io_vm1},${cpu_vm2},${ram_vm2},${io_vm2},0,0" >> "$OUT"
  sleep "$INTERVAL"
done
