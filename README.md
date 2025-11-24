[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/jQIzrBOF)

# Acesso à VM

Abaixo, seguem informações de login e senha para que o grupo possa acessar a VM disponível para a realização do projeto.

**login: gcloudpos01**

**senha: LuGfjMO6**
 
O acesso via SSH pode ser feito seguindo:

```bash
ssh <login>@andromeda.lasdpc.icmc.usp.br -p porta
```

# Portas de Acesso SSH

|   MÁQUINA   |   PORTA SSH   |
|-------------|---------------|
|     VM1     |     23191     |
|     VM2     |     23192     |

Com esta VM, o Docker pode ser utilizado, junto da criação do projeto da disciplina. 

O login do seu grupo tem poder de root, de modo que vocês podem instalar e configurar o que precisam. O Docker já está configurado para uso e não precisa ser instalado. Em caso de qualquer dúvida ou dificuldade de acesso, consultar o professor da disciplina: jcezar@icmc.usp.br

# Mapeamento de Portas (Exemplo)	

| Local (VM)    | Remota (WWW) - Porta Web   |
|---------------|----------------------------|
| 5191          | 5191                       |

# Acesso WEB	
http://andromeda.lasdpc.icmc.usp.br:porta-web	


# Descrição Wazuh

O Wazuh é uma plataforma open-source de segurança que faz monitoramento, coleta e análise de logs em tempo real para detectar ameaças e anomalias.
Ele funciona como um SIEM + HIDS, oferecendo detecção de intrusão, análise de integridade, resposta a incidentes e conformidade.
O Wazuh consiste em um agente Wazuh multiplataforma e três componentes centrais: o Wazuh server, o Wazuh indexer e o Wazuh dashboard.

# Opções de implantação
Para implantação pode-se utilizar o Wazuh Single-Node Stack, em que toda sua stack, ou seja, o manager, indexer e dashboard rodam em único servidor. Já o Wazuh Multi-Node Stack distribui esses modulos em múltiplos servidores. Para esse trabalho foi escolhida a implementação com Single-Node Stack.

# Requisitos de Hardware

| Requisito      | Especificação                                    |
|----------------|--------------------------------------------------|
| **Arquitetura**          | AMD64                                   |
| **CPU**                  | Mínimo de 4 cores                       |
| **Memória RAM**          | Pelo menos 8 GB para o host do Docker   |
| **Espaço em Disco**      | Pelo menos 50 GB para imagens e volumes |


# Requisitos de Software

- Sistema Operacional: Linux ou Windows
- Docker Engine / Docker Desktop
- Docker Composer
- Git

# Configurações iniciais

Para que a aplicação funcione adequadamente em sistemas operacionais Linux/Unix deve ser rodado o seguinte comando 

`sysctl -w vm.max_map_count=262144`

O comando irá definir o max_map_count do seu host Docker para 262144. Isso é necessário tendo em vista que o indexador do Wazuh cria um grande número de áreas de memória mapeadas virtualmente (VMAs), portanto, o kernel precisa estar configurado acima do limite padrão do Linux, que é 65530.

Caso queira usar o Docker como um usuário non-root, o seguinte comando deve ser executado também:

`usermod -aG docker <USER>`

Sendo que <USER> deve ser substituido pelo seu nome de usuário desejado

# Single-node stack deployment
Crie um clone do repositório Wazuh Docker no seu sistema

`git clone https://github.com/wazuh/wazuh-docker.git -b v4.13.0`

Navegue ate o diretório single-node para executar os comandos subsequentes

`cd wazuh-docker/single-node/`

É necessário fornecer certificados para cada nó a fim de garantir a comunicação segura entre eles na stack do Wazuh. Para isso, deve-se usar a imagem Docker wazuh-certs-generator para gerar certificados autoassinados para cada nó da sua stack.

`docker compose -f generate-indexer-certs.yml run --rm generator`

Os certificados gerados serão arquivados no diretório wazuh-docker/single-node/config/wazuh_indexer_ssl_certs

Para iniciar o Wazuh Docker em background o seguinte comando deve ser executado:

`docker compose up -d`

Após inicializar o single-node stack, o Wazuh dashboard pode ser acessado usando o endereço IP do host Docker ou localhost tal como no comando a seguir

`https://<DOCKER_HOST_IP>`

# Agente Wazuh
Executar o Wazuh Agent em um container Docker fornece uma alternativa leve para integração e coleta de logs via syslog, sem a necessidade de instalar o agente diretamente no host.

**Nota:** é importante que a versão do agente Wazuh seja igual ou maior que a do Wazuh Manager.


Clone o repositório oficial do Wazuh Docker

`git clone https://github.com/wazuh/wazuh-docker.git -b v4.14.1`

Acesse o diretório do Wazuh Agent

`cd wazuh-docker/wazuh-agent`

Edite o arquivo docker-compose.yml substituindo o <WAZUH_MANAGER_IP> pelo endereço IP do seu Wazuh Manager, conforme o trecho abaixo:

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

**Observação** as imagens do kali em geral não incluem o metapackage “default”. Por isso será necessário executar:

`apt update && apt -y install kali-linux-headless`

# Descrição Prometheus e Grafana 
O Prometheus é uma plataforma de monitoramento orientada a métricas, responsável por coletar e armazenar dados de desempenho dos serviços e containers, como CPU, memória, rede e ingestão de logs. O Grafana complementa o Prometheus oferecendo visualização em tempo real por meio de dashboards customizáveis, permitindo analisar o comportamento do SIEM durante os ataques e correlacionar métricas com eventos detectados pelo Wazuh.

# Passos de instalação Grafab

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


