# 🚀 Azure AKS Terraform Platform

> Plateforme Cloud complète déployée sur Microsoft Azure avec Terraform, AKS, Docker, ACR, Kubernetes, Helm, NGINX Ingress, cert-manager, GitHub Actions, HPA, Prometheus et Grafana.

## 📌 Présentation

Ce projet consiste à construire une plateforme Kubernetes complète sur **Microsoft Azure**, entièrement automatisée et reproductible avec **Terraform**.

L'objectif est de reproduire une architecture Cloud proche d'un environnement professionnel :

* Infrastructure as Code avec Terraform
* Cluster Kubernetes managé avec AKS
* Registry privé avec Azure Container Registry
* Application conteneurisée avec Docker
* Déploiement Kubernetes avec Helm
* Exposition HTTP avec NGINX Ingress Controller
* Gestion des certificats avec cert-manager
* CI/CD avec GitHub Actions
* Autoscaling avec Kubernetes HPA
* Monitoring avec Prometheus et Grafana
* Réseau Azure avec Virtual Network et Subnet
* Identité Azure avec Managed Identity et Service Principal pour GitHub Actions

Le projet permet ainsi de couvrir l'ensemble du cycle :

```text
Code
  ↓
GitHub
  ↓
GitHub Actions
  ↓
Docker Build
  ↓
Azure Container Registry
  ↓
Helm
  ↓
AKS
  ↓
NGINX Ingress
  ↓
Application
  ↓
Prometheus
  ↓
Grafana
```

---

# 🏗️ Architecture globale

```text
                         ┌──────────────────────┐
                         │       GitHub         │
                         │                      │
                         │ Application          │
                         │ Terraform            │
                         │ Helm                  │
                         └──────────┬───────────┘
                                    │
                               git push
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │   GitHub Actions     │
                         │                      │
                         │ Checkout             │
                         │ Azure Login           │
                         │ Docker Build           │
                         │ Docker Push            │
                         │ Helm Deploy            │
                         └──────────┬───────────┘
                                    │
                  ┌─────────────────┴─────────────────┐
                  │                                   │
                  ▼                                   ▼
       ┌──────────────────────┐             ┌──────────────────────┐
       │ Azure Container      │             │       Azure AKS      │
       │ Registry (ACR)       │             │                      │
       │                      │             │ Kubernetes Cluster   │
       │ aks-platform image   │             │                      │
       └──────────────────────┘             └──────────┬───────────┘
                                                       │
                              ┌────────────────────────┼─────────────────────┐
                              │                        │                     │
                              ▼                        ▼                     ▼
                       ┌─────────────┐         ┌─────────────┐       ┌─────────────┐
                       │ Deployment  │         │     HPA     │       │   Ingress   │
                       │             │         │             │       │    NGINX    │
                       │ Application │◄────────│ 1 → 3 Pods  │       │             │
                       └──────┬──────┘         └─────────────┘       └──────┬──────┘
                              │                                             │
                              │                                             ▼
                              │                                      HTTP traffic
                              │
                              ▼
                       ┌─────────────┐
                       │   Service   │
                       │  ClusterIP  │
                       └─────────────┘

                              Monitoring
                                  │
                    ┌─────────────┴─────────────┐
                    ▼                           ▼
              ┌─────────────┐             ┌─────────────┐
              │ Prometheus  │────────────►│   Grafana   │
              │             │             │             │
              │ Metrics     │             │ Dashboards  │
              └─────────────┘             └─────────────┘
```

---

# 📁 Structure du projet

```text
azure-aks-terraform-platform/
│
├── .github/
│   └── workflows/
│       └── build-push.yaml
│
├── app/
│   ├── Dockerfile
│   ├── package.json
│   └── ...
│
├── helm/
│   └── aks-platform/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── ingress.yaml
│           ├── hpa.yaml
│           └── ...
│
├── terraform/
│   ├── main.tf
│   └── .terraform.lock.hcl
│
└── README.md
```

---

# ☁️ Infrastructure Azure

L'infrastructure Azure est créée avec Terraform.

## Ressources principales

Terraform crée notamment :

* Resource Group
* Virtual Network
* Subnet
* Azure Container Registry
* Azure Kubernetes Service

La région utilisée pour le projet est :

```text
Poland Central
```

## Réseau

Le Virtual Network utilise :

```text
10.0.0.0/16
```

avec un subnet AKS :

```text
10.0.1.0/24
```

Le réseau Kubernetes utilise également un CIDR dédié aux Services :

```text
10.1.0.0/16
```

et le DNS Kubernetes :

```text
10.1.0.10
```

---

# 🏗️ Terraform

Terraform permet de définir toute l'infrastructure sous forme de code.

Exemple :

```hcl
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-terraform-platform"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = azurerm_subnet.aks.id
  }
}
```

Cela permet de recréer l'infrastructure sans avoir à configurer manuellement chaque ressource depuis Azure Portal.

## Commandes principales

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Pour détruire l'infrastructure :

```bash
terraform destroy
```

---

# 🐳 Docker

L'application est conteneurisée avec Docker.

L'image est construite avec :

```text
clementaksterraform.azurecr.io/aks-platform
```

Deux tags sont utilisés :

```text
latest
```

et surtout :

```text
<GitHub commit SHA>
```

L'utilisation du SHA permet d'identifier précisément quelle version du code est déployée.

---

# 📦 Azure Container Registry

L'image Docker est stockée dans Azure Container Registry.

Le pipeline GitHub Actions effectue :

```text
Docker Build
      ↓
Azure Login
      ↓
ACR Login
      ↓
Docker Push
```

L'image est ensuite récupérée par AKS lors du déploiement.

L'ACR utilise :

```text
admin_enabled = false
```

afin de ne pas utiliser un compte administrateur ACR avec username/password.

---

# ☸️ Kubernetes / AKS

Le cluster AKS possède un node pool système.

Configuration actuelle :

```text
VM                Standard_D2s_v3
Nodes             1
Min replicas      1
Max replicas      3
```

Le cluster utilise :

```text
Network plugin: Azure CNI
```

---

# ⎈ Helm

Helm permet de transformer les manifests Kubernetes en chart configurable.

Le chart contient notamment :

```text
Deployment
Service
Ingress
HPA
```

Les paramètres sont centralisés dans :

```text
helm/aks-platform/values.yaml
```

Par exemple :

```yaml
replicaCount: 1

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

resources:
  requests:
    cpu: 100m
    memory: 128Mi

  limits:
    cpu: 250m
    memory: 256Mi
```

Cela permet de modifier la configuration sans réécrire les manifests Kubernetes.

---

# 🌐 NGINX Ingress

L'application est exposée via un **NGINX Ingress Controller**.

Architecture :

```text
Internet
   │
   ▼
Azure Load Balancer
   │
   ▼
NGINX Ingress Controller
   │
   ▼
Ingress
   │
   ▼
Service
   │
   ▼
Pod
```

L'Ingress utilise actuellement :

```text
aks-platform.local
```

Le host permet à NGINX de déterminer quelle application doit recevoir la requête.

---

# 🔐 TLS avec cert-manager

Le projet utilise **cert-manager** pour automatiser la gestion des certificats TLS.

Un `ClusterIssuer` Let's Encrypt a été configuré.

Le `ClusterIssuer` utilisé est :

```text
letsencrypt-prod
```

Cependant, un certificat Let's Encrypt public nécessite un **vrai domaine DNS contrôlé par l'utilisateur**.

Le domaine local :

```text
aks-platform.local
```

ne peut donc pas être utilisé pour obtenir un certificat public Let's Encrypt.

Cette partie est volontairement laissée comme extension future si un vrai domaine est ajouté.

---

# 📈 Autoscaling avec HPA

Le projet utilise le **Horizontal Pod Autoscaler**.

L'objectif est d'adapter automatiquement le nombre de Pods à la charge CPU.

Configuration :

```text
Minimum : 1 Pod
Maximum : 3 Pods
Target CPU : 70%
```

Architecture :

```text
             CPU < 70%
                 │
                 ▼
              1 Pod


             CPU > 70%
                 │
                 ▼
            HPA scaling
                 │
                 ▼
           2 → 3 Pods
```

Un test de charge a été réalisé afin de vérifier que Kubernetes pouvait effectivement augmenter le nombre de replicas.

Après suppression de la charge, les replicas peuvent redescendre automatiquement.

---

# 📊 Monitoring

Le monitoring utilise :

* Prometheus
* Grafana
* Alertmanager
* Prometheus Operator
* Node Exporter

Le stack est déployé avec :

```text
kube-prometheus-stack
```

## Architecture

```text
Kubernetes
     │
     ├── Nodes
     ├── Pods
     ├── Deployments
     └── HPA
           │
           ▼
       Prometheus
           │
           ▼
        Grafana
```

Grafana permet notamment de visualiser :

* CPU
* mémoire
* nombre de Pods
* redémarrages de conteneurs
* replicas actuels du HPA
* replicas désirés du HPA

Cela permet de corréler la charge de l'application avec le comportement du HPA.

---

# 🔄 CI/CD avec GitHub Actions

Le pipeline CI/CD est déclenché lors d'un push sur `main`.

Workflow :

```text
git push
   │
   ▼
GitHub Actions
   │
   ├── Checkout
   │
   ├── Azure Login
   │
   ├── ACR Login
   │
   ├── Docker Build
   │
   ├── Docker Push
   │
   ├── AKS credentials
   │
   └── Helm deployment
          │
          ▼
         AKS
```

Le pipeline utilise une authentification Azure basée sur une identité dédiée à GitHub Actions.

Les credentials Azure ne sont pas stockés directement dans le repository.

Les valeurs sensibles sont stockées dans :

```text
GitHub Secrets
```

---

# 🔑 Sécurité GitHub Actions

GitHub Actions utilise notamment :

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

Ces valeurs permettent à GitHub Actions de s'authentifier auprès d'Azure.

L'identité utilisée par GitHub Actions possède uniquement les permissions nécessaires au fonctionnement du pipeline.

Un problème de permissions a notamment été rencontré avec :

```text
Microsoft.ContainerService/managedClusters/listClusterUserCredential/action
```

Le pipeline ne pouvait pas récupérer les credentials AKS.

La résolution a consisté à identifier **l'Object ID réellement utilisé par GitHub Actions** puis à lui attribuer le rôle :

```text
Azure Kubernetes Service Cluster User Role
```

sur le cluster AKS.

---

# 🧩 Problèmes rencontrés et solutions

Cette section est particulièrement importante car elle montre les compétences de troubleshooting développées pendant le projet.

## 1. Terraform refusait certains paramètres AKS

Une première configuration utilisait :

```text
enable_auto_scaling
```

Terraform retournait :

```text
Unsupported argument
```

La configuration a été adaptée à la version du provider AzureRM utilisée.

Le paramètre approprié dans la configuration finale est :

```text
auto_scaling_enabled
```

Cette erreur a permis de prendre en compte la différence entre la documentation/version du provider et la configuration réellement supportée.

---

## 2. Terraform refusait `default_node_pool`

Une autre erreur indiquait :

```text
Unsupported block type
default_node_pool
```

Le problème venait de la structure du bloc Terraform après modification du fichier.

La structure du resource `azurerm_kubernetes_cluster` a été corrigée.

Finalement :

```bash
terraform validate
```

et :

```bash
terraform plan
```

fonctionnaient correctement.

Le résultat final :

```text
No changes.
Your infrastructure matches the configuration.
```

---

## 3. Service Kubernetes et Ingress

Au début, le Service de l'application était de type :

```text
LoadBalancer
```

Puis l'architecture a été améliorée pour utiliser :

```text
Service → ClusterIP
```

avec :

```text
NGINX Ingress → LoadBalancer
```

Cette architecture est plus cohérente lorsqu'un Ingress Controller est utilisé.

---

## 4. Endpoint Kubernetes inaccessible depuis l'extérieur

Une requête vers :

```text
20.215.140.11
```

depuis la machine locale retournait :

```text
Connection timed out
```

alors que la même application répondait correctement depuis le cluster :

```text
HTTP/1.1 200 OK

{"status":"healthy"}
```

Cela a permis de déterminer que :

```text
Application       ✅
Service           ✅
Ingress            ✅
NGINX              ✅
```

étaient fonctionnels à l'intérieur du cluster.

Le problème concernait l'accès réseau externe au Load Balancer Azure, et non l'application elle-même.

Cette distinction est importante dans Kubernetes : un endpoint interne fonctionnel ne garantit pas qu'il soit accessible depuis Internet.

---

## 5. Service DNS non résolu

Un test avec :

```bash
kubectl run curl-test
```

a initialement été effectué dans le namespace `default`.

La commande essayait donc d'accéder à :

```text
http://aks-platform
```

mais le Service existait dans :

```text
aks-platform
```

Le DNS Kubernetes dépend notamment du namespace.

La résolution correcte peut être faite avec :

```text
aks-platform.aks-platform.svc.cluster.local
```

ou en exécutant le Pod de test directement dans le namespace concerné.

---

## 6. GitHub Actions n'avait pas les permissions AKS

Le pipeline échouait sur :

```text
az aks get-credentials
```

avec :

```text
AuthorizationFailed
```

Le problème était particulièrement intéressant : l'identité à laquelle un rôle avait été attribué n'était pas celle réellement utilisée par GitHub Actions.

Deux Object IDs différents avaient été identifiés.

Le véritable Object ID utilisé par GitHub Actions a finalement reçu :

```text
Azure Kubernetes Service Cluster User Role
```

Le pipeline a ensuite pu récupérer les credentials AKS et poursuivre son déploiement.

---

## 7. Grafana affichait trop de Pods

Une requête initiale utilisait :

```promql
count(
  kube_pod_info{
    namespace="aks-platform"
  }
)
```

Cette requête comptait tous les Pods du namespace.

Elle pouvait donc afficher un nombre supérieur au nombre de replicas du Deployment.

La requête a été affinée pour sélectionner uniquement les Pods de l'application :

```promql
count(
  kube_pod_info{
    namespace="aks-platform",
    pod=~"aks-platform-.*"
  }
)
```

Cela montre l'importance de construire des requêtes PromQL précises.

---

# 🔐 Gestion des secrets

Aucun secret Azure sensible n'est volontairement stocké dans le repository.

Les informations utilisées par GitHub Actions sont stockées dans :

```text
GitHub Secrets
```

Le repository contient uniquement les références :

```yaml
${{ secrets.AZURE_CLIENT_ID }}
${{ secrets.AZURE_TENANT_ID }}
${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

Les secrets réels ne sont donc pas présents dans le code source.

---

# 🧪 Tests réalisés

Plusieurs niveaux de tests ont été effectués.

## Application

```bash
curl /health
```

Résultat :

```json
{
  "status": "healthy"
}
```

## Kubernetes

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
kubectl get endpoints
```

## Helm

```bash
helm lint
helm template
helm list -A
```

## Terraform

```bash
terraform validate
terraform plan
```

Résultat final :

```text
No changes.
Your infrastructure matches the configuration.
```

## HPA

Le comportement de l'HPA a été testé avec une charge artificielle.

## Monitoring

Prometheus et Grafana ont été vérifiés avec :

```bash
kubectl get pods -A
kubectl get svc -A
```

---

# 🚀 Déploiement du projet

## Prérequis

Installer :

* Azure CLI
* Terraform
* kubectl
* Helm
* Docker
* Git

Être connecté à Azure :

```bash
az login
```

---

## Déployer l'infrastructure

```bash
cd terraform

terraform init
terraform validate
terraform plan
terraform apply
```

---

## Récupérer les credentials AKS

```bash
az aks get-credentials \
  --resource-group rg-aks-terraform \
  --name aks-terraform-platform
```

Vérifier :

```bash
kubectl get nodes
```

---

## Déployer Helm

```bash
helm upgrade --install aks-platform \
  ./helm/aks-platform \
  --namespace aks-platform \
  --create-namespace
```

---

## Vérifier l'application

```bash
kubectl get pods -n aks-platform
```

```bash
kubectl get svc -n aks-platform
```

```bash
kubectl get ingress -n aks-platform
```

---

# 📊 Accéder à Grafana

Grafana peut être exposé temporairement avec un port-forward :

```bash
kubectl port-forward \
  -n monitoring \
  svc/monitoring-grafana \
  3000:80
```

Puis :

```text
http://localhost:3000
```

---

# 🧹 Suppression de l'infrastructure

Le projet étant destiné à être utilisé comme environnement de démonstration, l'infrastructure peut être supprimée après utilisation.

Depuis le dossier Terraform :

```bash
terraform destroy
```

Cela permet d'éviter de laisser des ressources Azure actives inutilement.

---

# 💰 Coûts

Le projet utilise principalement des ressources Azure susceptibles d'être facturées selon l'utilisation.

Pour éviter des coûts inutiles :

```bash
terraform destroy
```

peut être exécuté une fois la démonstration terminée.

Les outils open source utilisés dans Kubernetes, tels que :

* Kubernetes
* Helm
* Prometheus
* Grafana
* cert-manager
* NGINX Ingress

ne nécessitent pas d'abonnement logiciel payant.

Cependant, **les ressources Azure sous-jacentes peuvent générer des coûts**.

---

# 🎯 Compétences démontrées

Ce projet permet de démontrer des compétences dans plusieurs domaines du Cloud Computing.

### Cloud

* Microsoft Azure
* Azure Kubernetes Service
* Azure Container Registry
* Azure Networking
* Azure Managed Identity

### Infrastructure as Code

* Terraform
* AzureRM Provider
* Infrastructure reproductible
* Terraform state

### Containers

* Docker
* Container Registry
* Images versionnées

### Kubernetes

* Pods
* Deployments
* Services
* Ingress
* HPA
* Namespaces
* Service Accounts
* RBAC

### DevOps

* GitHub Actions
* CI/CD
* Docker Build & Push
* Automated Helm Deployment

### Observabilité

* Prometheus
* Grafana
* Alertmanager
* Node Exporter
* PromQL

### Sécurité

* GitHub Secrets
* Azure RBAC
* Managed Identity
* Service Principal
* cert-manager
* TLS

---



# 📌 Résumé

Ce projet met en place une plateforme Kubernetes complète sur Azure en appliquant plusieurs pratiques modernes du Cloud et du DevOps.

L'infrastructure est déclarée avec **Terraform**, l'application est conteneurisée avec **Docker**, les images sont stockées dans **Azure Container Registry**, le déploiement Kubernetes est géré avec **Helm**, l'accès HTTP est assuré par **NGINX Ingress**, l'autoscaling est assuré par **HPA**, et l'observabilité est réalisée avec **Prometheus et Grafana**.

Le pipeline **GitHub Actions** automatise le cycle complet :

```text
Developer
    │
    │ git push
    ▼
GitHub
    │
    ▼
GitHub Actions
    │
    ├── Build Docker image
    ├── Push image → ACR
    ├── Authenticate → Azure
    └── Deploy → Helm
                  │
                  ▼
                 AKS
                  │
          ┌───────┼────────┐
          ▼       ▼        ▼
       Ingress   HPA    Monitoring
          │       │        │
          ▼       ▼        ▼
       App Pods  Scaling  Grafana
```

L'objectif principal du projet est de démontrer la capacité à **concevoir, déployer, automatiser, monitorer et maintenir une infrastructure Kubernetes Cloud complète**, tout en étant capable de diagnostiquer des problèmes réels de réseau, de permissions Azure, de Kubernetes et de CI/CD.
