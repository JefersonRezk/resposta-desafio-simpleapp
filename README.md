Desafio simpleapp-python

# Criando a imagem Python do desafio

Essa imagem inclui tudo o que é necessário para executar um aplicativo - o código ou binário, tempo de execução, dependências e quaisquer outros objetos do sistema de arquivos necessários.

Para concluir este tutorial, precisaremos das seguinte ferramentas:

Python versão 3.8 ou posterior;
Docker em execução localmente; 
Um IDE ou um editor de texto para editar arquivos. Usaremos o Visual Studio Code.

1-Exemplo de aplicação 
Vamos criar um aplicativo Python simples usando a estrutura Flask que usaremos como nosso exemplo. Crie um diretório em sua máquina local nomeado python-dockere siga as etapas abaixo para criar um servidor web simples.

cd /path/to/python-docker
python3 -m venv .venv
source .venv/bin/activate
(.venv) $ python3 -m pip install Flask
(.venv) $ python3 -m pip freeze > requirements.txt
(.venv) $ touch app.py

Agora, vamos adicionar algum código para lidar com solicitações da Web simples. Abra este diretório de trabalho em seu IDE favorito e insira o seguinte código no app.pyarquivo.

from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, Docker!'

2-Teste o aplicativo 
Vamos iniciar nosso aplicativo e verificar se ele está funcionando corretamente. Abra seu terminal e navegue até o diretório de trabalho que você criou.

cd /path/to/python-docker
source .venv/bin/activate
(.venv) $ python3 -m flask run

Para testar se o aplicativo está funcionando corretamente, abra um novo navegador e navegue até
http://localhost:5000.

Volte para o terminal em que nosso servidor está sendo executado e você verá as seguintes solicitações nos logs do servidor. Os dados e carimbo de data/hora serão diferentes em sua máquina.

127.0.0.1 - - [22/Sep/2020 11:07:41] "GET / HTTP/1.1" 200 -

3-Criação de um Dockerfile para Python
Agora que nosso aplicativo está funcionando corretamente, vamos dar uma olhada na criação de um Dockerfile.

Em seguida, precisamos adicionar uma linha em nosso Dockerfile que informe ao Docker qual imagem base gostaríamos de usar para nosso aplicativo.

#syntax=docker/dockerfile:1

FROM python:3.8-slim-buster

As imagens do Docker podem ser herdadas de outras imagens. Portanto, em vez de criar nossa própria imagem base, usaremos a imagem oficial do Python que já possui todas as ferramentas e pacotes necessários para executar um aplicativo Python.

Para facilitar a execução do restante de nossos comandos, vamos criar um diretório de trabalho. Isso instrui o Docker a usar esse caminho como o local padrão para todos os comandos subsequentes. Ao fazer isso, não precisamos digitar caminhos de arquivo completos, mas podemos usar caminhos relativos com base no diretório de trabalho.

WORKDIR /app

Normalmente, a primeira coisa que você faz depois de baixar um projeto escrito em Python é instalar pippacotes. Isso garante que seu aplicativo tenha todas as suas dependências instaladas.

Antes de podermos executar pip3 install, precisamos colocar nosso requirements.txt arquivo em nossa imagem. Usaremos o COPY comando para fazer isso. O COPY comando usa dois parâmetros. O primeiro parâmetro informa ao Docker quais arquivos você gostaria de copiar para a imagem. O segundo parâmetro informa ao Docker para onde você deseja que os arquivos sejam copiados. Vamos copiar o requirements.txt arquivo em nosso diretório de trabalho /app.

COPY requirements.txt requirements.txt

Assim que tivermos nosso requirements.txt arquivo dentro da imagem, podemos usar o RUN comando para executar o comando pip3 install. Isso funciona exatamente como se estivéssemos executando pip3 install localmente em nossa máquina, mas desta vez os módulos são instalados na imagem.

RUN pip3 install -r requirements.txt

Neste ponto, temos uma imagem baseada no Python versão 3.8 e instalamos nossas dependências. O próximo passo é adicionar nosso código fonte na imagem. Usaremos o COPY comando exatamente como fizemos com nosso requirements.txt arquivo acima.

COPY . .

Este COPY comando pega todos os arquivos localizados no diretório atual e os copia na imagem. Agora, tudo o que precisamos fazer é dizer ao Docker qual comando queremos executar quando nossa imagem for executada dentro de um contêiner. Fazemos isso usando o CMD comando. Observe que precisamos tornar o aplicativo visível externamente (ou seja, de fora do contêiner) especificando --host=0.0.0.0.

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]


Aqui está o Dockerfile completo do desafio.


#syntax=docker/dockerfile:1

FROM python:3

COPY . /app

WORKDIR /app

RUN pip install pip

CMD [ "python", "./app.py" ]


4-Enviando a imagem para  DockerHub 
docker image push jefersonrezk/simpleapp-python:v1 
docker image push jefersonrezk/simpleapp-python:latest 

## Criação e aplicação dos arquivos yaml para o Kubernetes

1-Services (simpleapp-svc.yaml)

apiVersion: v1
kind: Service
metadata:
  name: simpleapp-svc
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30000
  selector:
    app: simpleapp-python

kubectl apply -f simpleapp-svc.yaml


2-Configmap (simpleapp-cm.yaml)

apiVersion: v1
kind: ConfigMap
metadata:
  name: simpleapp-cm
data:
  key: value

kubectl apply -f simpleapp-cm.yaml


3-Ingress (simleapp-ingress.yaml)

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simpleapp-ingress
  labels:
    name: simpleapp-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: app.prova
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: nginx
            port: 
              number: 80

kubectl apply -f simpleapp-ingress.yaml

### Configrar GKE no Google com Terraform

1-Configurar Provedor Terraform GCP
Primeiro de tudo, precisamos declarar um provedor de terraform. Podemos pensar nisso como uma biblioteca com métodos para criar e gerenciar infraestrutura em um ambiente específico. Neste caso, é um Google Cloud Platform.

#https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
    project = "desafio"
    region = "us-central1"
}

2-Configurar back-end do Terraform GCS
Quando o recursos no GCP for criado, como VPC, o Terraform precisa de uma maneira de acompanhá-los. Se você simplesmente aplicar o terraform agora, ele manterá todo o estado localmente em seu computador. É muito difícil colaborar com outros membros da equipe e é fácil destruir acidentalmente toda a sua infraestrutura. Você pode declarar o back-end do Terraform para usar armazenamento remoto. Como estamos criando uma infraestrutura no GCP, a abordagem lógica seria usar o Google Storage Bucket para armazenar o estado do Terraform. Você precisa fornecer um nome de bucket e um prefixo.

#http://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "jefersonrezk-tf-state-staging"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "~> 4.0"
    }
  }
}

3-Criar VPC no GCP usando o Terraform
Nada impede de usar o VPC existente para criar um cluster Kubernetes, mas criarei toda a infraestrutura usando o Terraform para esta lição. Por exemplo, em vez de recurso, podemos usar a palavra-chave data para importá-lo para o Terraform. Antes de criar o VPC em um novo projeto do GCP, você precisa habilitar a API de computação. Para criar um cluster do GKE, você também precisa habilitar a API do google de contêiner.

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "main" {
  name                            = "main"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}

4-Criar sub-rede no GCP usando o Terraform
A próxima etapa é criar uma sub-rede privada para colocar os nós do Kubernetes. Quando você usa o cluster do GKE, o plano de controle do Kubernetes é gerenciado pelo Google e você só precisa se preocupar com o posicionamento dos trabalhadores do Kubernetes.

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
resource "google_compute_subnetwork" "private" {
  name                     = "private"
  ip_cidr_range            = "10.0.0.0/18"
  region                   = "us-central1"
  network                  = google_compute_network.main.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = "10.48.0.0/14"
  }
  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = "10.52.0.0/20"
  }
}

5-Criar Cloud Router no GCP usando o Terraform
Em seguida, precisamos criar o Cloud Router para divulgar as rotas. Ele será usado com o gateway NAT para permitir que VMs sem endereços IP públicos acessem a Internet. Por exemplo, os nós do Kubernetes poderão extrair imagens do docker do hub do docker.

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router
resource "google_compute_router" "router" {
  name    = "router"
  region  = "us-central1"
  network = google_compute_network.main.id
}

6-Criar Cloud NAT no GCP usando o Terraform
Agora, vamos criar o Cloud NAT. Dê um nome e uma referência ao Cloud Router. Em seguida, a região us-central1. Você pode decidir anunciar este Cloud NAT para todas as sub-redes nessa VPC ou pode selecionar algumas específicas. Neste exemplo, escolherei apenas a sub-rede privada.

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat
resource "google_compute_router_nat" "nat" {
  name   = "nat"
  router = google_compute_router.router.name
  region = "us-central1"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat.self_link]
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address
resource "google_compute_address" "nat" {
  name         = "nat"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [google_project_service.compute]
}

7-Criar firewall no GCP usando o Terraform
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

8-Criar cluster do GKE usando o Terraform
Finalmente, chegamos ao recurso Kubernetes. Primeiro, precisamos configurar o plano de controle do próprio cluster.

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
resource "google_container_cluster" "primary" {
  name                     = "primary"
  location                 = "us-central1-a"
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.main.self_link
  subnetwork               = google_compute_subnetwork.private.self_link
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  networking_mode          = "VPC_NATIVE"

  #Optional, if you want multi-zonal cluster
  node_locations = [
    "us-central1-b"
  ]

  addons_config {
    http_load_balancing {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "desafio.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}

8-Criar pools de nós do GKE usando o Terraform
Antes de podermos criar grupos de nós para o Kubernetes, se quisermos seguir as práticas recomendadas, precisamos criar uma conta de serviço dedicada. Criaremos dois grupos de nós.

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "kubernetes" {
  account_id = "kubernetes"
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
resource "google_container_node_pool" "general" {
  name       = "general"
  cluster    = google_container_cluster.primary.id
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = false
    machine_type = "e2-small"

    labels = {
      role = "general"
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_container_node_pool" "spot" {
  name    = "spot"
  cluster = google_container_cluster.primary.id

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 10
  }

  node_config {
    preemptible  = true
    machine_type = "e2-small"

    labels = {
      team = "devops"
    }

    taint {
      key    = "instance_type"
      value  = "spot"
      effect = "NO_SCHEDULE"
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

9-Aplicar Terraforma
Para executar o Terraform localmente, será precisa configurar as credenciais padrão do aplicativo. Execute o comando gcloud auth application-default login. Ele abrirá o navegador padrão, onde você precisará concluir a autorização.

gcloud auth application-default login

O primeiro comando a ser executado é o terraform init. Ele fará o download do provedor do Google e inicializará o back-end do Terraform para usar o baket GS. Para realmente criar todos os recursos que definimos no Terraform, precisamos executar terraform apply.

terraform init

terraform apply

10-Demonstração de escalonamento automático do GKE (exemplo 1)
Agora vamos implantar alguns exemplos no Kubernetes. O primeiro é o objeto de implantação para demonstrar o escalonamento automático do cluster. Vamos usar a imagem nginx e definir duas réplicas. Queremos implantá-lo no grupo de instâncias spot que não tem nenhum nó no momento.

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
      tolerations:
      - key: instance_type
        value: spot
        effect: NoSchedule
        operator: Equal
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: team
                operator: In
                values:
                - devops
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - nginx
            topologyKey: kubernetes.io/hostname


Podemos usar o comando kubectl apply e fornecer um caminho para a pasta ou arquivo, neste caso, exemplo um.

kubectl apply -f k8s/1-example.yaml


11-Demonstraçãode identidade da carga de trabalho do GKE (exemplo 2)
No exemplo a seguir, mostrarei como usar a identidade da carga de trabalho e conceder acesso ao pod para listar os buckets GS. Em primeiro lugar, precisamos criar uma conta de serviço no Google Cloud Platform.

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "service-a" {
  account_id = "service-a"
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_member" "service-a" {
  project = "desafio"
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.service-a.email}"
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam
resource "google_service_account_iam_member" "service-a" {
  service_account_id = google_service_account.service-a.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:desafio.svc.id.goog[staging/service-a]"
}


12-Hora de criar o segundo exemplo. O primeiro será um namespace de teste. Em seguida, a implantação. Dê a ele um nome gcloud e especifique o mesmo namespace de preparação.

---
apiVersion: v1
kind: default2
metadata:
  name: staging
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    iam.gke.io/gcp-service-account: service-a@desafio.iam.gserviceaccount.com
  name: service-a
  namespace: staging
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gcloud
  namespace: staging
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gcloud
  template:
    metadata:
      labels:
        app: gcloud
    spec:
      serviceAccountName: service-a
      containers:
      - name: cloud-sdk
        image: google/cloud-sdk:latest
        command: [ "/bin/bash", "-c", "--" ]
        args: [ "while true; do sleep 30; done;" ]
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: iam.gke.io/gke-metadata-server-enabled
                operator: In
                values:
                - "true"

Criar objeto de implantação

kubectl apply -f k8s/2-example.yaml

13-Implante o Nginx Ingress Controller no GKE (Exemplo 3)
Para o último exemplo, deixe-me implantar o controlador de entrada nginx usando o helm. Adicione o repositório ingress-nginx.


helm repo add ingress-nginx \
  https://kubernetes.github.io/ingress-nginx

Atualizar índice do leme

helm repo update

Para substituir algumas variáveis ​​padrão, crie o arquivo nginx-values.yaml.

---
controller:
  config:
    compute-full-forwarded-for: "true"
    use-forwarded-headers: "true"
    proxy-body-size: "0"
  ingressClassResource:
    name: external-nginx
    enabled: true
    default: false
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: app.kubernetes.io/name
              operator: In
              values:
                - ingress-nginx
        topologyKey: "kubernetes.io/hostname"
  replicaCount: 1
  admissionWebhooks:
    enabled: false
  service:
    annotations:
      cloud.google.com/load-balancer-type: External
  metrics:
    enabled: false


helm install my-ing ingress-nginx/ingress-nginx \
  --namespace ingress \
  --version 4.0.17 \
  --values nginx-values.yaml \
  --create-namespace


Reutilizaremos o objeto de implantação criado anteriormente para a demonstração de escalonamento automático. Este serviço selecionará esses pods usando o rótulo app: nginx. Então o ingresso em si.

---
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: default
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ing
  namespace: default
spec:
  ingressClassName: external-nginx
  rules:
  - host: api.devopsbyexample.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80

Criar Serviço e Entrada.

kubectl apply -f k8s/3-example.yaml