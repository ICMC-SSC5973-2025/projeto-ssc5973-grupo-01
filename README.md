[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/jQIzrBOF)

# Acesso à VM

Abaixo, seguem informações de login e senha para que o grupo possa acessar a VM disponível para a realização do projeto.

**login: gcloudpos01**

**senha: LuGfjMO6**
 
O acesso via SSH pode ser feito seguindo:

```bash
ssh <login>@andromeda.lasdpc.icmc.usp.br -p porta
```

Com esta VM, o Docker pode ser utilizado, junto da criação do projeto da disciplina. 

O login do seu grupo tem poder de root, de modo que vocês podem instalar e configurar o que precisam. O Docker já está configurado para uso e não precisa ser instalado. Em caso de qualquer dúvida ou dificuldade de acesso, consultar o professor da disciplina: jcezar@icmc.usp.br

# Mapeamento de Portas (Exemplo)	

| Local (VM)    | Remota (WWW) - Porta Web   |
|---------------|----------------------------|
| 5191          | 5191                       |

Consulte a porta-web correspondente ao seu grupo na planilha com informações do grupo lá no moodle.

# Acesso WEB	
http://andromeda.lasdpc.icmc.usp.br:porta-web	

---
```

Wazuh consists of a multi-platform Wazuh agent and three central components: the Wazuh server, the Wazuh indexer, and the Wazuh dashboard. Refer to the Wazuh components documentation for more information.

Deployment options
Wazuh supports the deployment of its central components and agent on Docker.

Single-node stack: This stack deploys one of each Wazuh central component as a separate container. It includes:

Wazuh indexer container: Stores and indexes security data collected by the Wazuh manager.

Wazuh manager container: Analyzes collected security events, applies detection rules, and manages Wazuh agents.

Wazuh dashboard container: Centralized web interface for monitoring, searching, and managing Wazuh.

It provides persistent storage and configurable certificates for secure communication.

Multi-node stack: This stack deploys each Wazuh component as a separate container. It includes:

Three Wazuh indexer containers: Work together in a cluster to store and replicate indexed data, ensuring scalability and fault tolerance.

Two Wazuh manager containers: One master and one worker node. The master coordinates agent management and rule updates, while the worker provides redundancy and load distribution.

One Wazuh dashboard container.

One Nginx proxy container: This provides a single secure entry point that load balances traffic between multiple Wazuh manager nodes for high availability. The Nginx container acts as a reverse proxy, distributing incoming requests across the available manager nodes and providing SSL termination for secure communication.

This deployment stack provides persistent storage, secure communication, and high availability.

Wazuh agent: This deploys the Wazuh agent as a container on your Docker host.

Prerequisites
Before deploying Wazuh on Docker, ensure your environment meets the following requirements.

System requirements
Single-node stack deployment
Operating system: Linux or Windows

Architecture: AMD64

CPU: At least 4 cores

Memory: At least 8 GB of RAM for the Docker host

Disk space: At least 50 GB storage for Docker images and data volumes

Multi-node stack deployment
Operating system: Linux or Windows

Architecture: AMD64

CPU: At least 4 cores

Memory: At least 16 GB for the Docker host

Disk space: At least 100 GB storage for Docker images and data volumes

Wazuh agent deployment
Operating system: Linux or Windows

Architecture: AMD64

CPU: At least 2 cores

Memory: At least 1 GB of RAM for the Docker host

Disk space: At least 10 GB storage for Docker images and logs

Required software
Docker Engine / Docker Desktop: Use the latest stable version.

Linux: Docker Engine

Windows: Docker Desktop (requires WSL 2)

Docker Compose: Latest stable version (included with Docker Desktop on Windows; install separately on Linux if needed).

Git: For cloning the Wazuh Docker repository.

Linux/Unix host requirements
Additional configuration is required to ensure proper functionality when running Wazuh Docker on a Linux/Unix operating system.

Run the following command to set the max_map_count on your Docker host to 262144. The Wazuh indexer creates a large number of virtual memory-mapped areas (VMAs), so the kernel must be configured above the Linux default limit of 65530. A VMA is a region of memory that the kernel reserves to let applications like the Wazuh indexer access files directly from disk as if they were in RAM.


sysctl -w vm.max_map_count=262144
Warning This configuration allows more files and index segments to be mapped to memory simultaneously without errors or crashes. If you don't set a minimum value of at least 262144 for max_map_count on your Linux host, the Wazuh indexer will not work correctly.
If you want to use Docker as a non-root user, you should add your user to the docker group using the following command:


usermod -aG docker <USER>
Replace <USER> with your username. Log out and back in for changes to take effect.

Exposed ports
The following ports are exposed when the Wazuh central components are deployed.

Wazuh dashboard HTTPS

Wazuh central components
Below are the steps for deploying the Wazuh central components in single-node and multi-node stacks.

Warning Do not run the single-node and multi-node stacks at the same time on the same Docker host. Both stacks use overlapping resources (such as container names, ports, and volumes), which can lead to conflicts, unexpected behavior, or data corruption.
Single-node stack deployment
Follow the steps below to deploy the Wazuh central components in a single-node stack.

Note All deployment commands provided apply to both Windows and Linux environments.
Cloning the repository
Clone the Wazuh Docker repository to your system:


git clone https://github.com/wazuh/wazuh-docker.git -b v4.13.0
Navigate to the single-node directory to execute all the following commands.


cd wazuh-docker/single-node/
Certificate generation
You must provide certificates for each node to secure communication between them in the Wazuh stack. You have two alternatives:

Wazuh self-signed certificates

Your own certificates

Wazuh self‑signed certificatesYour own certificates
You must use the wazuh-certs-generator Docker image to generate self-signed certificates for each node of the stack.

Optional: Add the following to the generate-indexer-certs.yml file if your system uses a proxy. If not, skip this step. Replace <YOUR_PROXY_ADDRESS_OR_DNS> with your proxy information.


# Wazuh App Copyright (C) 2017, Wazuh Inc. (License GPLv2)
services:
  generator:
    image: wazuh/wazuh-certs-generator:0.0.2
    hostname: wazuh-certs-generator
    volumes:
      - ./config/wazuh_indexer_ssl_certs/:/certificates/
      - ./config/certs.yml:/config/certs.yml
    environment:
      - HTTP_PROXY=<YOUR_PROXY_ADDRESS_OR_DNS>
Run the following command to generate the desired certificates:


docker compose -f generate-indexer-certs.yml run --rm generator
The generated certificates will be stored in the wazuh-docker/single-node/config/wazuh_indexer_ssl_certs directory.

Deployment
Start the Wazuh Docker deployment using the docker compose command:

BackgroundForeground

docker compose up -d
Note Docker does not dynamically reload the configuration. After changing a component's configuration, you need to restart the stack.
Accessing the Wazuh dashboard
After deploying the single-node stack, you can access the Wazuh dashboard using your Docker host's IP address or localhost.


https://<DOCKER_HOST_IP>
Note If you use a self-signed certificate, your browser will display a warning that it cannot verify the certificate's authenticity.
This is the default username and password to access the Wazuh dashboard:

Username: admin

Password: SecretPassword

Refer to the changing the default password of Wazuh users section to learn more about additional security.

Note

To determine when the Wazuh indexer is up, the Wazuh dashboard container uses curl to repeatedly send queries to the Wazuh indexer API (port 9200). You can expect to see several Failed to connect to Wazuh indexer port 9200 log messages or Wazuh dashboard server is not ready yet until the Wazuh indexer is started. Then the setup process continues normally. It takes about one minute for the Wazuh indexer to start up. You can find the default Wazuh indexer credentials in the docker-compose.yml file.

Multi-node stack deployment
Follow the steps below to deploy the Wazuh central components in a multi-node stack.

Note All deployment commands provided apply to both Windows and Linux environments.
Cloning the repository
Clone the Wazuh Docker repository to your system:


git clone https://github.com/wazuh/wazuh-docker.git -b v4.13.0
Navigate to the multi-node directory to execute all the following commands.


cd wazuh-docker/multi-node/
Certificate generation
You must provide certificates for each node to secure communication between them in the Wazuh stack. You have two alternatives:

Wazuh self-signed certificates

Your own certificates

Wazuh self‑signed certificatesYour own certificates
You must use the wazuh-certs-generator Docker image to generate self-signed certificates for each node of the stack.

Optional: Add the following to the generate-indexer-certs.yml file if your system uses a proxy. If not, skip this step. Replace <YOUR_PROXY_ADDRESS_OR_DNS> with your proxy information.


# Wazuh App Copyright (C) 2017, Wazuh Inc. (License GPLv2)
services:
  generator:
    image: wazuh/wazuh-certs-generator:0.0.2
    hostname: wazuh-certs-generator
    volumes:
      - ./config/wazuh_indexer_ssl_certs/:/certificates/
      - ./config/certs.yml:/config/certs.yml
    environment:
      - HTTP_PROXY=<YOUR_PROXY_ADDRESS_OR_DNS>
Run the following command to generate the desired certificates:


docker compose -f generate-indexer-certs.yml run --rm generator
The generated certificates will be stored in the wazuh-docker/multi-node/config/wazuh_indexer_ssl_certs directory.

Deployment
Start the Wazuh Docker deployment using the docker compose command:

BackgroundForeground

docker compose up -d
Note Docker does not dynamically reload the configuration. After changing a component's configuration, you need to restart the stack.
Accessing the Wazuh dashboard
After deploying the multi-node stack, you can access the Wazuh dashboard using your Docker host's IP address or localhost.


https://<DOCKER_HOST_IP>
Note If you use a self-signed certificate, your browser will display a warning that it cannot verify the certificate's authenticity.
This is the default username and password to access the Wazuh dashboard:

Username: admin

Password: SecretPassword
