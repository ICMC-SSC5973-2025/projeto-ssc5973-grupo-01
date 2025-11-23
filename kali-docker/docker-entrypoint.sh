#!/usr/bin/env bash
set -e

# Gera chaves SSH se não existirem
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  dpkg-reconfigure openssh-server || true
fi

mkdir -p /var/run/sshd

# Inicia o serviço SSH
service ssh start || /usr/sbin/sshd

# Ajusta permissões do /root caso use volumes
chown -R root:root /root || true

# Mantém o container ativo e pronto
exec "$@"
