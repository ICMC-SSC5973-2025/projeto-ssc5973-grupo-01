#!/bin/bash

# Arquivo CSV de saída
OUTPUT="metrics_vm1.csv"

# Intervalo entre coletas (em segundos)
INTERVAL=2

# Disco a monitorar (defina com: lsblk)
DISK="vda"

# Interface de rede (verifique com: ip a)
NET_IF="enp1s0"

# Se o arquivo não existir, cria com cabeçalho
if [ ! -f "$OUTPUT" ]; then
    echo "timestamp,cpu_percent,mem_used_percent,read_kb_s,write_kb_s,rx_kb_s,tx_kb_s" > "$OUTPUT"
fi

echo "Coletando CPU, Memória, I/O de disco ($DISK) e Rede ($NET_IF) a cada ${INTERVAL}s..."
echo "Pressione CTRL+C para parar."

#############################################
# CAPTURA INICIAL (baseline)
#############################################

# Função para obter estatísticas de disco
get_disk_stats() {
    awk -v disk="$DISK" '$3==disk {print $6, $10}' /proc/diskstats
}

# Função para estatísticas de rede
get_net_stats() {
    awk -v iface="$NET_IF" '$0 ~ iface {print $2, $10}' /proc/net/dev
}

# Baselines
read LAST_READ LAST_WRITE <<< "$(get_disk_stats)"
read LAST_RX LAST_TX <<< "$(get_net_stats)"
LAST_TS=$(date +%s)

#############################################
# LOOP DE COLETA
#############################################
while true; do
    sleep $INTERVAL

    TS=$(date +"%Y-%m-%d %H:%M:%S")
    NOW_TS=$(date +%s)
    ELAPSED=$((NOW_TS - LAST_TS))

    ######################
    # CPU
    ######################
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')

    ######################
    # MEMÓRIA
    ######################
    MEM=$(free | awk '/Mem:/ {printf("%.2f", $3/$2 * 100.0)}')

    ######################
    # DISCO (read/write)
    ######################
    read CUR_READ CUR_WRITE <<< "$(get_disk_stats)"
    READ_KB_S=$(echo "scale=2; ($CUR_READ - $LAST_READ) / $ELAPSED" | bc)
    WRITE_KB_S=$(echo "scale=2; ($CUR_WRITE - $LAST_WRITE) / $ELAPSED" | bc)

    # Atualiza baselines disco
    LAST_READ=$CUR_READ
    LAST_WRITE=$CUR_WRITE

    ######################
    # REDE (rx/tx)
    ######################
    read CUR_RX CUR_TX <<< "$(get_net_stats)"
    RX_KB_S=$(echo "scale=2; ($CUR_RX - $LAST_RX) / $ELAPSED" | bc)
    TX_KB_S=$(echo "scale=2; ($CUR_TX - $LAST_TX) / $ELAPSED" | bc)

    # Atualiza baselines rede
    LAST_RX=$CUR_RX
    LAST_TX=$CUR_TX

    LAST_TS=$NOW_TS

    ######################
    # REGISTRO NO CSV
    ######################
    echo "$TS,$CPU,$MEM,$READ_KB_S,$WRITE_KB_S,$RX_KB_S,$TX_KB_S" >> "$OUTPUT"

done
