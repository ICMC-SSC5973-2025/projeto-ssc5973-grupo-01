# Dockerfile - kali-docker (repetível e persistente)
FROM kalilinux/kali-rolling

ARG DEBIAN_FRONTEND=noninteractive
ARG PACKAGES_FILE=packages.txt

# Pacotes base + openssh
RUN apt-get update && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg2 wget apt-transport-https \
    openssh-server dialog locales sudo procps iproute2 iputils-ping \
 && rm -rf /var/lib/apt/lists/*

# Criar usuário não-root (para uso diário)
RUN useradd -m -s /bin/bash kgcloudpos01 && echo "kgcloudpos01:Palillo2025!" | chpasswd && adduser kgcloudpos01 sudo

# Diretório para chaves do sshd
RUN mkdir -p /var/run/sshd

# Copiar lista de pacotes adicionais
COPY packages.txt /tmp/packages.txt
RUN apt-get update && \
      xargs -r -a /tmp/packages.txt apt-get install -y --no-install-recommends --fix-missing || true && \
      rm -rf /var/lib/apt/lists/* /tmp/packages.txt

# Entry point
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /root

EXPOSE 2222/tcp

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]
