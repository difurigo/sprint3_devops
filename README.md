

---

## 👥 Integrantes da Equipe
- Nome 1 — RM: 558935 — Lu Vieira Santos
- Nome 2 — RM: 555656 — Melissa Pereira
- Nome 3 — RM: 558755 — E‑mail: Diego Furigo

---

## 🧭 Domínio e Justificativa
O domínio escolhido representa a **operação de pátios da Mottu**. Há relação natural entre **pátios**, **funcionários** e a **designação de gerentes** por pátio — cenário comum em operações logísticas reais. Isso permite avaliar relacionamentos 1‑N e N‑N simples, além de autenticação e gestão de acesso futura.

### Entidades principais (mínimo 3)
1. **Pátio** (`Patio`) – local físico onde motos/equipes operam.  
2. **Funcionário** (`Funcionario`) – usuário operacional, alocado em um pátio.  
3. **Gerente** (`Gerente`) – designa qual funcionário gerencia um determinado pátio (relação Funcionario ↔ Pátio).

> Essas 3 entidades cobrem o requisito de **“mínimo 3 entidades principais”** e fazem sentido de negócio, pois a operação diária depende de cadastro de pátios, quadro de pessoas e responsáveis por cada pátio.

---

## 📝 Descrição do Projeto
API .NET 9.0 para gestão de **Pátios**, **Funcionários** e **Gerentes** da Mottu.  
O objetivo desta Sprint foi **containerizar** a aplicação e o banco de dados, e **provisionar toda a infraestrutura em nuvem (Azure)** de forma automatizada via CLI, aplicando práticas de **DevOps**.

---

## ⚙️ Arquitetura

- **API**: .NET 9.0 (C#) + Entity Framework Core + Swagger
- **Banco de Dados**: MySQL 8.0 (rodando em container no Azure)
- **Containerização**: Docker (multi-stage build)
- **Provisionamento**: Azure CLI (Infrastructure as Code)
- **Registry**: Azure Container Registry (ACR)
- **Execução**: Azure Container Instances (ACI)  
- **CI/CD**: Build local + Push para ACR + Deploy automático em containers

---

## 🚀 Passo a Passo (Execução e Deploy)

### 0️⃣ Pré-requisitos

- Conta no [Azure](https://portal.azure.com/) com CLI configurado (`az --version`)
- Docker instalado e em execução (`docker --version`)
- Código fonte da API com Dockerfile

---

### 1️⃣ Limpeza (caso precise regravar)

Para recriar tudo do zero:

```bash
az container delete -g mottu-rg -n mottu-api -y
az container delete -g mottu-rg -n mottu-mysql -y
az group delete --name mottu-rg --yes --no-wait
```

---

### 2️⃣ Login no Azure e criação do Resource Group

```bash
az login
az group create --name mottu-rg --location brazilsouth
```

---

### 3️⃣ Criar o Azure Container Registry (ACR)

Crie um repositório privado de imagens Docker no Azure (nome global único):

```bash
az acr create --resource-group mottu-rg --name mottuacr01 --sku Basic --admin-enabled true
```

O comando retorna o `loginServer`, por exemplo:

```
"loginServer": "mottuacr01.azurecr.io"
```

---

### 4️⃣ Build e Push da Imagem da API

No diretório do projeto onde está o Dockerfile:

```bash
docker build -t mottuapi:local .
az acr login --name mottuacr01
docker tag mottuapi:local mottuacr01.azurecr.io/mottuapi:1.0
docker push mottuacr01.azurecr.io/mottuapi:1.0
```

Isso gera a imagem da API e envia para o ACR.

---

### 5️⃣ Subir o Banco MySQL em um Container no Azure

Crie um container MySQL 8.0:

```bash
az container create \
  --resource-group mottu-rg \
  --name mottu-mysql \
  --image mysql:8.0 \
  --cpu 1 --memory 1 \
  --os-type Linux \
  --ports 3306 \
  --environment-variables MYSQL_ROOT_PASSWORD="SENHA" MYSQL_DATABASE=motosdb \
  --ip-address Public
```

Pegue o IP público:

```bash
az container show -g mottu-rg -n mottu-mysql --query "ipAddress.ip" -o tsv
```

Guarde o IP (ex.: `0.000.00.000`) para a conexão da API.

---

### 6️⃣ Deploy da API no Azure Container Instances (ACI)

Recupere as credenciais do ACR:

```bash
az acr credential show --name mottuacr01
```

Crie o container da API com um nome DNS único:

```bash
az container create \
  --resource-group mottu-rg \
  --name mottu-api \
  --image mottuacr01.azurecr.io/mottuapi:1.0 \
  --cpu 1 --memory 1.5 \
  --os-type Linux \
  --ports 8080 \
  --dns-name-label mottuapi-IDENTIFICADOR_UNICO \
  --environment-variables \
     ASPNETCORE_ENVIRONMENT=Production \
     ASPNETCORE_URLS="http://+:8080" \
     ConnectionStrings__DefaultConnection="server=<IP_MYSQL>;port=3306;database=motosdb;user=root;password=SENHA" \
  --registry-login-server mottuacr01.azurecr.io \
  --registry-username <USER_ACR> \
  --registry-password "<SENHA_ACR>" \
  --ip-address Public
```

Verifique o FQDN gerado:

```bash
az container show -g mottu-rg -n mottu-api --query "ipAddress.fqdn" -o tsv
```

Exemplo:

```
mottuapi-IDENTIFICADOR_UNICO.brazilsouth.azurecontainer.io
```

---

### 7️⃣ Testar a API

Abra no navegador:

```
http://mottuapi-IDENTIFICADOR_UNICO.brazilsouth.azurecontainer.io:8080
```

A interface do Swagger permite:

- Criar/atualizar/excluir/listar **Pátios**, **Funcionários** e **Gerentes**  
- Testar endpoints `GET`, `POST`, `PUT` e `DELETE`

Exemplos de requisições JSON:

**Criar Pátio**
```json
{
  "nome": "Pátio Centro",
  "endereco": "Rua Principal 123, São Paulo",
  "gerenteId": null
}
```

**Criar Funcionário**
```json
{
  "nome": "João da Silva",
  "email": "joao.silva@mottu.com",
  "senha": "senha123",
  "patioId": 1
}
```

**Criar Gerente**
```json
{
  "funcionarioId": 1,
  "patioId": 1
}
```

---

## 📄 Licença
Uso acadêmico. Ajuste conforme a política da disciplina.
