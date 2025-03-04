# Not So Simple Ecommerce IaC

Este é o repositório utilizado dentro do curso para gerenciar toda infraestrutura do projeto `not-so-simple-ecommerce`. Este projeto é composto por diversas stacks na pasta `terraform`, visando provisionar toda infraestrutura necessária para subir a aplicação `not-so-simple-ecommerce` na AWS.

Os playbooks Ansible vão se conectar nas máquinas provisionadas pelo Terraform através de um `inventário dinâmico` e criar um Cluster Kubernetes com kube-adm, Production Grade.

Toda essa stack é desenvolvida do absoluto zero, aula por aula. Recomendo que você assista as aulas em paralelo ao estudo do código deste repositório na sua conta AWS para melhor entendimento do que está provisionando.

---

## 🛠️ Configuração e Execução

### 1. Configuração da Role na AWS

Antes de realizar o deployment das stacks do Terraform, crie uma Role na sua conta AWS:

**Atenção:** Substitua as variáveis `<YOUR_EXTERNAL_ID>`, `<YOUR_ACCOUNT>` e `<YOUR_USER>`.

```bash
aws iam create-role \
    --role-name DevOpsNaNuvemRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<YOUR_ACCOUNT>:user/<YOUR_USER>"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "<YOUR_EXTERNAL_ID>"
                }
            }
        }]
    }'
```

📌 **Observação:** Para dúvidas, consulte as primeiras aulas do Módulo 3 (Setup AWS/Terraform).

---

### 2. Anexar Permissões Administrativas

Anexe permissões administrativas à role criada:

```bash
aws iam attach-role-policy \
    --role-name DevOpsNaNuvemRole \
    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

---

### 3. Substituição da String `<YOUR_ROLE_ARN>` nos Arquivos Terraform

#### 🐧 **(WSL/Linux)**

```bash
find . -type f -name "*.tf" -exec sed -i \
    's|<YOUR_ROLE_ARN>|arn:aws:iam::<YOUR_ACCOUNT>:role/DevOpsNaNuvemRole|g' {} +
```

#### 🍎 **(MacOS)**

```bash
find . -type f -name "*.tf" -exec sed -i '' \
    's|<YOUR_ROLE_ARN>|arn:aws:iam::<YOUR_ACCOUNT>:role/DevOpsNaNuvemRole|g' {} +
```

**Atenção:** Substitua `<YOUR_ACCOUNT>` pela sua conta AWS.

---

### 4. Deploy da Stack `backend`

A stack `backend` cria o bucket S3 e a DynamoDB para o Terraform state locking e remote backend:

```bash
cd ./terraform/backend && terraform init && terraform apply -auto-approve
```

📌 **Observação:** O comando considera que você está na pasta root da aplicação.

---

### 5. Deploy da Stack `networking`

Crie a base de redes para as próximas stacks:

```bash
cd ./terraform/networking && terraform init && terraform apply -auto-approve
```

---

### 6. Deploy da Stack `server`

Crie a infraestrutura de instâncias EC2 e recursos para o Cluster Kubernetes:

```bash
cd ./terraform/server && terraform init && terraform apply -auto-approve
```

---

### 7. Deploy da Stack `serverless`

Provisione filas, bancos de dados, buckets S3, Lambdas e outras dependências da aplicação:

```bash
cd ./terraform/serverless && terraform init && terraform apply -auto-approve
```

📌 **Observação:** Ao atualizar o código das Lambdas, execute o `tsc` para gerar o `build/index.js` (Módulo 05).

---

### 8. Deploy da Stack `site`

Configure a infraestrutura de frontend:

```bash
cd ./terraform/site && terraform init && terraform apply -auto-approve
```

---

### 9. Configuração das Credenciais AWS nos Arquivos YAML

Substitua as variáveis `<YOUR_ACCESS_KEY>`, `<YOUR_SECRET_ACCESS_KEY>` e `<YOUR_AWS_PROFILE>` nos arquivos `.yml`:

```bash
find . -type f -name "*.yml" -exec sed -i '' \
    's|<YOUR_ACCESS_KEY>|<YOUR_REAL_ACCESS_KEY>|g' {} + &&
find . -type f -name "*.yml" -exec sed -i '' \
    's|<YOUR_SECRET_ACCESS_KEY>|<YOUR_REAL_SECRET_ACCESS_KEY>|g' {} + &&
find . -type f -name "*.yml" -exec sed -i '' \
    's|<YOUR_AWS_PROFILE>|<YOUR_REAL_AWS_PROFILE>|g' {} +
```

---

### 10. Execução do Ansible para Criar o Cluster Kubernetes

```bash
export BECOME_PASSWORD="<YOUR_PASSWORD>"
ansible-playbook -i production.aws_ec2.yml site.yml --extra-vars "ansible_become_password=$BECOME_PASSWORD"
```

---

### 11. Conexão no Cluster Kubernetes Localmente

```bash
aws ssm start-session --target <ANY_MASTER_INSTANCE_ID>
sudo su
cat /etc/kubernetes/admin.conf
```

---

### 12. Teste da Conexão com o Cluster Kubernetes

```bash
aws ssm start-session \
    --target <ANY_MASTER_INSTANCE_ID> \
    --document-name AWS-StartPortForwardingSession \
    --parameters 'portNumber=6443,localPortNumber=6443'

export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get nodes
```

---

## 🗑️ Deletar Infraestrutura Criada

Para destruir os recursos provisionados, siga esta ordem:

```bash
cd ./terraform/site && terraform destroy -auto-approve
cd ./terraform/serverless && terraform destroy -auto-approve
cd ./terraform/server && terraform destroy -auto-approve
cd ./terraform/networking && terraform destroy -auto-approve
```

**Atenção:** Mantenha a ordem ao destruir as stacks para evitar dependências quebradas.
