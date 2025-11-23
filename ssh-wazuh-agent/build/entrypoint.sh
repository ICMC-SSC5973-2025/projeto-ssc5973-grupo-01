#!/usr/bin/env bash
set -e

# Timezone
if [ -n "${TZ}" ]; then
  ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone
fi

# Cria usuário de teste (para brute force)
if ! id -u "${SSH_USER:-lab}" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "${SSH_USER:-lab}"
  echo "${SSH_USER:-lab}:${SSH_PASSWORD:-lab123}" | chpasswd
  usermod -aG sudo "${SSH_USER:-lab}"
fi

# Garante que auth.log exista (e rsyslog registra authpriv.*)
touch /var/log/auth.log
if ! grep -qE '^\s*authpriv\.\*\s+/var/log/auth\.log' /etc/rsyslog.d/50-default.conf; then
  echo 'authpriv.* /var/log/auth.log' >> /etc/rsyslog.d/50-default.conf
fi

# Configura Wazuh Agent apontando para o Manager
if [ -n "${WAZUH_MANAGER}" ]; then
  sed -ri "s#<address>.*</address>#<address>${WAZUH_MANAGER}</address>#g" /var/ossec/etc/ossec.conf
fi

# Define o nome do agente (aparece no Manager)
if [ -n "${WAZUH_AGENT_NAME}" ]; then
  sed -ri "s#<agent_name>.*</agent_name>#<agent_name>${WAZUH_AGENT_NAME}</agent_name>#g" /var/ossec/etc/ossec.conf || \
  sed -i "/<client>/a \ \ \ \ <agent_name>${WAZUH_AGENT_NAME}</agent_name>" /var/ossec/etc/ossec.conf
fi

# (Opcional) Enrolamento com senha, se seu manager usa authd com credencial
if [ -n "${WAZUH_ENROLLMENT_PASSWORD}" ]; then
  /var/ossec/bin/agent-auth -m "${WAZUH_MANAGER}" -P "${WAZUH_ENROLLMENT_PASSWORD}" || true
fi

exec "$@"
