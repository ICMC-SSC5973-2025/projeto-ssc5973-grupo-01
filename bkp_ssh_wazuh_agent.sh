#!/bin/bash
# =============================================
#  Backup automático do container ssh-wazuh-agent
#  Data de execução: $(date)
# =============================================

# Diretório de destino do backup
BKP_DIR="/home/gcloudpos01/bkps_dockers/ssh-wazuh-agent_281025"
DATE=$(date +%F)

# Volumes do container
VOL_OSSEC="ssh-wazuh-agent_ssh_ossec"
VOL_LOGS="ssh-wazuh-agent_ssh_logs"
VOL_SSH="ssh-wazuh-agent_ssh_etc"

# Diretório do projeto (ajuste se necessário)
PROJ_DIR="/home/gcloudpos01/ssh-wazuh-agent"

# Cria o diretório de backup (se ainda não existir)
mkdir -p "$BKP_DIR"

echo "============================================="
echo "Iniciando backup do ambiente ssh-wazuh-agent..."
echo "Destino: $BKP_DIR"
echo "Data: $DATE"
echo "============================================="

# -------------------------
#  Backup do /var/ossec
# -------------------------
echo "Backup do volume: $VOL_OSSEC"
docker run --rm -v ${VOL_OSSEC}:/data -v ${BKP_DIR}:/backup alpine \
  tar czf /backup/ossec_bkp_${DATE}.tar.gz -C /data .
echo "Backup /var/ossec concluído!"

# -------------------------
#  Backup do /var/log
# -------------------------
echo "Backup do volume: $VOL_LOGS"
docker run --rm -v ${VOL_LOGS}:/data -v ${BKP_DIR}:/backup alpine \
  tar czf /backup/logs_bkp_${DATE}.tar.gz -C /data .
echo "Backup /var/log concluído!"

# -------------------------
#  Backup do /etc/ssh
# -------------------------
echo "Backup do volume: $VOL_SSH"
docker run --rm -v ${VOL_SSH}:/data -v ${BKP_DIR}:/backup alpine \
  tar czf /backup/ssh_bkp_${DATE}.tar.gz -C /data .
echo "Backup /etc/ssh concluído!"

# -------------------------
# Backup do projeto (build + compose)
# -------------------------
if [ -d "$PROJ_DIR" ]; then
  echo "➡️  Backup da estrutura do projeto Docker..."
  tar czf ${BKP_DIR}/project_build_${DATE}.tar.gz -C "$PROJ_DIR" build docker-compose.yml
  echo "Estrutura do projeto salva!"
else
  echo "Diretório do projeto não encontrado em $PROJ_DIR"
fi

# -------------------------
#  Verificação final
# -------------------------
echo "Arquivos de backup criados:"
ls -lh ${BKP_DIR}/*.tar.gz

echo "Backup concluído com sucesso!"
echo "============================================="
