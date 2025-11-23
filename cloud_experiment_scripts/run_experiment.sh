#!/usr/bin/env bash
# run_experiment.sh
RUN_ID=$1; F1=$2; F2=$3; F3=$4; DURATION=${5:-600}
export RUN_ID="$RUN_ID"; export F1="$F1"; export F2="$F2"; export F3="$F3"
mkdir -p experiments/run_${RUN_ID}
OUT_METRICS="experiments/run_${RUN_ID}/metrics_${RUN_ID}.csv"
./collect_metrics.sh "$OUT_METRICS" 1 "$DURATION" vm1 &
COL_PID=$!
sleep 5
./attack_hydra.sh 10.1.3.192 root /usr/share/wordlists/rockyou.txt "$F1"
./inject_marker_and_measure.sh /var/log/auth.log http://10.1.3.191:55000 wazuh_user wazuh_pass >> experiments/run_${RUN_ID}/latency_log.txt &
sleep "$DURATION"
kill "$COL_PID" || true
echo "run $RUN_ID complete, metrics in $OUT_METRICS"
