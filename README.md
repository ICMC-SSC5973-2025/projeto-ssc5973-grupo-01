[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/jQIzrBOF)

# Accessing the VM

Below, you will find the login and password information so that the group can access the VM available for the project.

**login: gcloudpos01**

**password: XXXX**
 
Access via SSH can be done by following these steps:

```bash
ssh <login>@andromeda.lasdpc.icmc.usp.br -p porta
```

# SSH Access Ports

|   MACHINE   |   SSH PORT   |
|-------------|---------------|
|     VM1     |     23191     |
|     VM2     |     23192     |

With this VM, Docker can be used along with the creation of the course project.

Your group login has root privileges, so you can install and configure what you need. Docker is already configured for use and does not need to be installed. If you have any questions or difficulties accessing it, please consult the course instructor: **jcezar@icmc.usp.br**

# Port Mapping (Example)

| Local (VM)    | Remote (WWW) - Web Port   |
|---------------|----------------------------|
| 5191          | 5191                       |

# Web Acess	
http://andromeda.lasdpc.icmc.usp.br:porta-web	


# Description of Wazuh

Wazuh is an open-source security platform that performs real-time monitoring, log collection, and analysis to detect threats and anomalies.
It functions as a SIEM + HIDS, offering intrusion detection, integrity analysis, incident response, and compliance.
Wazuh consists of a cross-platform Wazuh agent and three core components: the Wazuh server, the Wazuh indexer, and the Wazuh dashboard.

# Deployment Options
For deployment, you can use Wazuh Single-Node Stack, where your entire stack, i.e., the manager, indexer, and dashboard, run on a single server. Wazuh Multi-Node Stack, on the other hand, distributes these modules across multiple servers. For this project, the Single-Node Stack implementation was chosen.

# Hardware Requirements
|------------------------------------------------------------|
| **Requirement**   | **Specification**                      |
|-------------------|----------------------------------------|
| **Architecture**  | AMD64                                  |
| **CPU**           | Minimum of 4 cores                     |
| **RAM Memory**    | At least 8 GB for the Docker host      |
| **Disk Space**    | At least 50 GB for images and volumes  |
|------------------------------------------------------------|

# Software Requirements

- Operating System: Linux or Windows
- Docker Engine / Docker Desktop
- Docker Composer
- Git

# Initial Settings

For the application to function properly on Linux/Unix operating systems, the following command must be run:
`sysctl -w vm.max_map_count=262144`

The command will set the `max_map_count` of your Docker host to 262144. This is necessary because the Wazuh indexer creates a large number of virtually mapped memory areas (VMAs), therefore the kernel needs to be configured above the default Linux limit of 65530.

If you want to use Docker as a non-root user, the following command should also be executed:
`usermod -aG docker <USER>`

Where <USER> should be replaced with your desired username.

# Single-node stack deployment
Create a clone of the Wazuh Docker repository on your system:
`git clone https://github.com/wazuh/wazuh-docker.git -b v4.13.0`

Navigate to the single-node directory to execute the subsequent commands:
`cd wazuh-docker/single-node/`

It is necessary to provide certificates for each node in order to ensure secure communication between them in the Wazuh stack. To do this, you should use the wazuh-certs-generator Docker image to generate self-signed certificates for each node in your stack.

`docker compose -f generate-indexer-certs.yml run --rm generator`

The generated certificates will be archived in the wazuh-docker/single-node/config/wazuh_indexer_ssl_certs directory.

To start Wazuh Docker in the background, the following command must be executed:

`docker compose up -d`

After initializing the single-node stack, the Wazuh dashboard can be accessed using the Docker host's IP address or localhost, as in the following command.

`https://<DOCKER_HOST_IP>`

# Wazuh Agent
Running the Wazuh Agent in a Docker container provides a lightweight alternative for integration and log collection via syslog, without the need to install the agent directly on the host.

**Note: It is important that the Wazuh agent version is the same as or higher than the Wazuh Manager version.**

Clone the official Wazuh Docker repository.

`git clone https://github.com/wazuh/wazuh-docker.git -b v4.14.1`

Access the Wazuh Agent directory.
`cd wazuh-docker/wazuh-agent`

Edit the docker-compose.yml file, replacing <WAZUH_MANAGER_IP> with the IP address of your Wazuh Manager, as shown in the excerpt below:
`environment: - WAZUH_MANAGER_SERVER=<WAZUH_MANAGER_IP>`

Inicie o container do Wazuh Agent

`docker compose up -d`

# Descrição Kali Linux / Hydra
O Kali Linux é uma distribuição focada em testes de intrusão e segurança ofensiva, contendo diversas ferramentas de ataque e auditoria. Neste projeto, ele é utilizado como ambiente para executar ataques de força bruta SSH. Já o Hydra é a ferramenta empregada para automatizar essas tentativas de autenticação, permitindo ajustar parâmetros como número de threads, taxa de tentativas e credenciais testadas, gerando tráfego malicioso controlado para avaliação do SIEM.

# Passos de instalação Kali 

A Kali fornece imagens oficiais do Kali Docker que são atualizadas semanalmente no Docker Hub, dessa forma, é possível escolher a que melhor se adequa ao projeto 

A mais indicada para propósito geral é a `kalilinux/kali-rolling` por acompanhar continuamente o repositório de pacotes kali-rolling, assim como as imagens padrão.

Para fazer o download dessa imagem basta executar o comando 

`docker pull docker.io/kalilinux/kali-rolling`

**Observação: as imagens do kali em geral não incluem o metapackage “default”. Por isso será necessário executar:**

`apt update && apt -y install kali-linux-headless`

# Descrição Prometheus e Grafana 
O Prometheus é uma plataforma de monitoramento orientada a métricas, responsável por coletar e armazenar dados de desempenho dos serviços e containers, como CPU, memória, rede e ingestão de logs. O Grafana complementa o Prometheus oferecendo visualização em tempo real por meio de dashboards customizáveis, permitindo analisar o comportamento do SIEM durante os ataques e correlacionar métricas com eventos detectados pelo Wazuh.

# Passos de instalação Prometheus e Grafana
Objetivo: monitorar a VM (CPU, memória, disco, rede) e os containers (CPU, memória, rede, I/O) usando Prometheus + Grafana com cAdvisor e Node Exporter.

Pré‑requisitos:
- Docker e Docker Compose já instalados na VM.
- Acesso SSH à VM1.
- Portas web do grupo: 5291 (Prometheus), 5391 (Grafana). Opcional: 5392 (cAdvisor), 5393 (Node Exporter para debug).

Estrutura na VM:
```
/home/gcloudpos01/monitoring
├── docker-compose.yml
└── prometheus/
    └── prometheus.yml
```

- Criar arquivos de configuração [docker-compose.yml](https://github.com/ICMC-SSC5973-2025/projeto-ssc5973-grupo-01/blob/main/monitoring/docker-compose.yml) e [prometheus.yml](https://github.com/ICMC-SSC5973-2025/projeto-ssc5973-grupo-01/blob/main/monitoring/prometheus/prometheus.yml)
- Subir a stack:
```
cd ~/monitoring
docker compose up -d
```

# Ambiente de Experimentação
O ambiente experimental consiste em duas máquinas virtuais (VMs), configuradas para emular um endpoint monitorado e um servidor SIEM centralizado

* VM1 (Wazuh Server, Prometheus e Grafana) - Responsável por receber e correlacionar eventos, aplicar regras de detecção, gerar alertas e monitorar métricas de CPU, memória, rede e ingestão de logs em tempo real.

* VM2 (Wazuh Agent e Kali Linux / Hydra) - Monitora o serviço SSH local e envia logs para o servidor. No mesmo host são gerados ataques de força bruta SSH com diferentes intensidades, controlando número de threads, atacantes e taxa de tentativas.

Essa arquitetura separa geração de eventos, processamento pelo SIEM e observabilidade, permitindo execuções repetíveis para avaliar latência de detecção, consumo de recursos e comportamento de ingestão sob ataques SSH controlados.

# Passos para realização de Ataques

## VM1
Antes de iniciar os ataques, é necessário executar o script `leia_metricas.sh` na VM1. Esse script coleta continuamente os dados de utilização do sistema durante a execução dos ataques e os registra no arquivo `metrics_vm1.csv`.

Após a conclusão dos ataques, utilize o script Python `gera_graficos.py` para processar o arquivo `metrics_vm1.csv` e gerar automaticamente os gráficos de análise.

## VM2

* Verificar contêineres em execução: `docker ps` - devem estar ativos os containers referentes ao agente wazuh ssh e ao kali-linux

* Para ataques externos, usar o kali linux instalado em sua VM pessoal, para ataques internos acessar shell bash do kali-docker: `docker exec -it kali-docker bash`

* Em um terminal sepaarado acesse o shell bash do ssh-wazuh-agent: `docker exec -it ssh_wazuh_agent bash`

* No container agente wazuh ssh podemos verificar em tempo real, por meio de impressão na tela, a leitura do log auth.log por meio do comando: `tail -f /var/log/auth.log`

* Por meio do Kali (interno ou externo) executar o script de ataque `./bfexp.sh`


# Configurações experimentais

Podem ser variados, para fim de estudo de diferentes casos, o hardware disponível ao container que recebe os ataques, além da frequência e intensidade desses ataques

Por meio da flag `-t` no script bfexp.sh podemos controlar o número de threads executadas em paralelo durante o ataque `hydra -L ${USER_LIST} -P ${PASS_LIST} ssh://$TARGET_IP:$SSH_PORT -t 32 -f -V `

Já as limitações de hardware são configuradas pelos parâmetros `mem_limit` e `cpus` do `single-node/docker-compose.yml`, que devem estar inclusas nas cláusulas de cada service declarado, nominalmente o `wazuh indexer`, `wazuh manager` e `wazuh dashboard`


