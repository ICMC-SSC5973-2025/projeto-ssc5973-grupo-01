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
