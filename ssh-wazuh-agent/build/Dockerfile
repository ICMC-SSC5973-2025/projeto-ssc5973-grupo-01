FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

# Pacotes base: OpenSSH, rsyslog (para /var/log/auth.log), supervisor (multi-serviço), utilitários
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openssh-server rsyslog supervisor curl ca-certificates gnupg lsb-release sudo vim tzdata && \
    rm -rf /var/lib/apt/lists/*

# Diretórios necessários
RUN mkdir -p /var/run/sshd /var/log/supervisor

# ---------- Instalação Wazuh Agent 4.13.x (Debian 12) ----------
# Repo oficial Wazuh
RUN curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor > /usr/share/keyrings/wazuh.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
      > /etc/apt/sources.list.d/wazuh.list && \
    apt-get update && \
    apt-get install -y wazuh-agent && \
    rm -rf /var/lib/apt/lists/*

# Copia supervisord e entrypoint
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Garante que rsyslog vai escrever auth.log
RUN sed -ri 's/^#?module\(load="imklog"\)/module(load="imklog")/' /etc/rsyslog.conf || true && \
    sed -ri 's/^#?module\(load="imuxsock"\)/module(load="imuxsock")/' /etc/rsyslog.conf || true && \
    grep -q "authpriv.*" /etc/rsyslog.d/50-default.conf || true

# SSH: harden básico; habilita senha (para seus testes)
RUN sed -ri 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -ri 's/^#?UsePAM .*/UsePAM yes/' /etc/ssh/sshd_config

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
