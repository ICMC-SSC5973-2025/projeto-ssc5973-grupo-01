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

| **Requirement**   | **Specification**                      |
|-------------------|----------------------------------------|
| **Architecture**  | AMD64                                  |
| **CPU**           | Minimum of 4 cores                     |
| **RAM Memory**    | At least 8 GB for the Docker host      |
| **Disk Space**    | At least 50 GB for images and volumes  |


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

Start the Wazuh Agent container

`docker compose up -d`

# Description Kali Linux / Hydra
Kali Linux is a distribution focused on penetration testing and offensive security, containing various attack and auditing tools. In this project, it is used as an environment to execute SSH brute-force attacks. Hydra is the tool used to automate these authentication attempts, allowing the adjustment of parameters such as the number of threads, attempt rate, and tested credentials, generating controlled malicious traffic for SIEM evaluation.

# Kali Installation Steps

Kali provides official Kali Docker images that are updated weekly on Docker Hub, allowing you to choose the one that best suits your project.

The most suitable for general purposes is `kalilinux/kali-rolling`, as it continuously includes the kali-rolling package repository, just like the standard images.

To download this image, simply run the command:

`docker pull docker.io/kalilinux/kali-rolling`

**Note: Kali images generally do not include the "default" metapackage. Therefore, you will need to run:**

`apt update && apt -y install kali-linux-headless`

# Description of Prometheus and Grafana
Prometheus is a metrics-driven monitoring platform responsible for collecting and storing performance data from services and containers, such as CPU, memory, network, and log ingestion. Grafana complements Prometheus by offering real-time visualization through customizable dashboards, allowing analysis of SIEM behavior during attacks and correlation of metrics with events detected by Wazuh.

# Prometheus and Grafana Installation Steps
Objective: To monitor the VM (CPU, memory, disk, network) and containers (CPU, memory, network, I/O) using Prometheus + Grafana with cAdvisor and Node Exporter.

# Prerequisites:
- Docker and Docker Compose already installed on the VM.
- SSH access to VM1.
- Group web ports: 5291 (Prometheus), 5391 (Grafana). Optional: 5392 (cAdvisor), 5393 (Node Exporter for debugging).

VM Structure:
```
/home/gcloudpos01/monitoring
├── docker-compose.yml
└── prometheus/
    └── prometheus.yml
```

- Create configuration files [docker-compose.yml](https://github.com/ICMC-SSC5973-2025/projeto-ssc5973-grupo-01/blob/main/monitoring/docker-compose.yml) e [prometheus.yml](https://github.com/ICMC-SSC5973-2025/projeto-ssc5973-grupo-01/blob/main/monitoring/prometheus/prometheus.yml)
- Raise the stack:
```
cd ~/monitoring
docker compose up -d
```

# Experimental Environment
The experimental environment consists of two virtual machines (VMs), configured to emulate a monitored endpoint and a centralized SIEM server.

* VM1 (Wazuh Server, Prometheus, and Grafana) - Responsible for receiving and correlating events, applying detection rules, generating alerts, and monitoring CPU, memory, network, and log ingestion metrics in real time.

* VM2 (Wazuh Agent and Kali Linux / Hydra) - Monitors the local SSH service and sends logs to the server. On the same host, SSH brute-force attacks of varying intensities are generated, controlling the number of threads, attackers, and attempt rate.

This architecture separates event generation, SIEM processing, and observability, allowing for repeatable executions to evaluate detection latency, resource consumption, and ingestion behavior under controlled SSH attacks.

# Steps for Performing Attacks

## VM1
Before starting the attacks, it is necessary to run the `read_metrics.sh` script on VM1. This script continuously collects system usage data during the execution of the attacks and logs it in the file
`metrics_vm1.csv`.

After the attacks are complete, use the Python script `gera_graficos.py` to process the `metrics_vm1.csv` file and automatically generate the analysis graphs.

## VM2

* Check running containers: `docker ps` - the containers related to the wazuh ssh agent and kali-linux must be active.

* For external attacks, use Kali Linux installed on your personal VM; for internal attacks, access the kali-docker bash shell: `docker exec -it kali-docker bash`

* In a separate terminal, access the bash shell of the ssh-wazuh-agent: `docker exec -it ssh_wazuh_agent bash`

* In the wazuh ssh agent container, we can verify in real time, by printing to the screen, the reading of the auth.log using the command: `tail -f /var/log/auth.log`

* Through Kali (internal or external), execute the attack script `./bfexp.sh`


# Experimental configurations

The hardware available to the container receiving the attacks, as well as the frequency and intensity of these attacks, can be varied for the purpose of studying different cases.

Using the `-t` flag in the bfexp.sh script, we can control the number of threads running in parallel during the attack: `hydra -L ${USER_LIST} -P ${PASS_LIST} ssh://$TARGET_IP:$SSH_PORT -t 32 -f -V`

Hardware limitations are configured by the `mem_limit` and `cpus` parameters in `single-node/docker-compose.yml`, which must be included in the clauses of each declared service, namely `wazuh indexer`, `wazuh manager`, and `wazuh dashboard`.


