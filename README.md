# Not So Simple Ecommerce IaC
Este é o repositório utilizado dentro do curso para gerenciar toda infraestrutura do projeto `not-so-simple-ecommerce`. Este projeto é composto por diversas stacks abaixo da pasta terraform,visando provisionar toda infraestrutura necessária para subir a aplicação not-so-simple-ecommerce na AWS.

Os playbooks ansibles em sua conjuntura vão se conectar nas máquinas provisionadas pelo terraform através de uma configuração de `inventário 
dinâmico` e então criar um Cluster Kubernetes com kube-adm, Production Grade.

Toda essa stack é desenvolvida do absoluto zero aula por aula, minha recomendação é que você assista as aulas em paralelo ao estudo do código deste repositório na sua conta AWS para melhor entendimento do que está provisionando.

# Configuração e Execução
1.Antes de realizar o deployment das stacks do terraform, primeiramente é necessário realizar a configuração de uma Role na sua conta AWS. Para realizar a criação de uma role na sua conta AWS, execute:

**Atenção:** Realize a substituição das variáveis `<YOUR_EXTERNAL_ID>`,`<YOUR_ACCOUNT>` e `<YOUR_USER>`.

```bash
$ aws iam create-role \
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

**Observação**: Caso tenha qualquer dúvida nesta parte, verifique as primeiras aulas do Módulo 3 onde fazemos o setup AWS/Terraform.

2.Agora anexe permissões administrativas a role criada executando o comando:

```bash
$    aws iam attach-role-policy \
        --role-name DevOpsNaNuvemRole \
        --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

3.Realize a substituição da string `<YOUR_ROLE_ARN>` nos arquivos terraform (.tf) do repositório pelo valor correto executando o comando:

```bash
$ find . -type f -name "*.tf" -exec sed -i 's|<YOUR_ROLE_ARN>|arn:aws:iam::<YOUR_ACCOUNT>:role/DevOpsNaNuvemRole|g' {} +
```
**Atenção:** Realize a substituição da variável `<YOUR_ACCOUNT>`.

Realize a substituição da string `<YOUR_EXTERNAL_ID>` nos arquivos terraform (.tf) do repositório pelo valor verdadeiro `<YOUR_REAL_EXTERNAL_ID>` executando o comando:

```bash
$ find . -type f -name "*.tf" -exec sed -i 's|<YOUR_EXTERNAL_ID>|<YOUR_REAL_EXTERNAL_ID>|g' {} +
```
**Atenção:** Realize a substituição das variável `<YOUR_REAL_EXTERNAL_ID>`.

4.Antes de executar qualquer uma das stacks do terraform, execute primeiramente a stack `backend`, essa stack é composta por bucket s3 e dynamo table para habilitar state locking e remote backend em todas outras stacks do terraform:

```bash
$ cd ./terraform/backend && terraform init && terraform apply -auto-approve
```
**Observação:** O comando acima considera que você está na pasta root da aplicação.

5.Agora realize o deployment da stack `networking`, pois é a base para todas as próximas:

```bash
$ cd ./terraform/networking && terraform init && terraform apply -auto-approve
```

6.Agora realize o deployment da stack `server`, para criar toda parte de instâncias EC2 e afins para o 
Cluster Kubernetes: 

```bash
$ cd ./terraform/server && terraform init && terraform apply -auto-approve
```

7.Agora realize o deployment da stack `serverless`, para criar toda parte de filas, bancos de dados relacionais,
não relacionais, buckets s3, lambdas e demais dependências da aplicação `not-so-simple-ecommerce`: 

```bash
$ cd ./terraform/serverless && terraform init && terraform apply -auto-approve
```
**Observação**: Referente ao código das lambdas, sempre que atualizar o arquivo index.ts, lembre-se de fazer a transpilação utilizando o `tsc` para gerar o arquivo build/index.js - conforme aprendido no módulo 05.

8.Agora realize o deployment da stack `site`, para criar a infraestrutura de frontend: 

```bash
$ cd ./terraform/site && terraform init && terraform apply -auto-approve
```
Se chegou neste ponto, toda sua infraestrutura foi provisionada, continue para os passos seguintes,
se quiser subir seu Cluster Kubernetes na AWS usando as instâncias EC2 criadas na stack server.

9.Para rodar os playbooks ansible, primeiramente é necessário realizar a configuração das credencias da AWS, então realize a substituição das variáveis `<YOUR_REAL_SECRET_ACCESS_KEY>`, `<YOUR_REAL_SECRET_ACCESS_KEY>`, `<YOUR_REAL_AWS_PROFILE>` pelos seus respectivos valores nos arquivos YAMLs (.yml) executando o comando:

```bash
$ find . -type f -name "*.yml" -exec sed -i 's|<YOUR_ACCESS_KEY>|<YOUR_REAL_ACCESS_KEY>|g' {} + &&
$ find . -type f -name "*.yml" -exec sed -i 's|<YOUR_SECRET_ACCESS_KEY>|<YOUR_REAL_SECRET_ACCESS_KEY>|g' {} + &&
$ find . -type f -name "*.yml" -exec sed -i 's|<YOUR_AWS_PROFILE>|<YOUR_REAL_AWS_PROFILE>|g' {} +
```

9.1.Realize a execução do comando `pwd` no diretório raiz onde clonou este projeto e copie todo valor antes do diretório `not-so-simple-ecommerce-iac`, substitua a string `<YOUR_REPOSITORY_PATH>` nos arquivos YAMLs (.yml) por este valor no lugar da string `<YOUR_REAL_REPOSITORY_PATH>` executando o comando:

```bash
$ find . -type f -name "*.yml" -exec sed -i 's|<YOUR_REPOSITORY_PATH>|<YOUR_REAL_REPOSITORY_PATH>|g' {} +
```

10.Para executar a criação do Cluster Kubernetes nas instâncias provisionados pela stack `server`, execute:

```bash
$ export BECOME_PASSWORD="<YOUR_PASSWORD>"
$ ansible-playbook -i production.aws_ec2.yml site.yml --extra-vars "ansible_become_password=$BECOME_PASSWORD"
```

11.Para se conectar no Cluster Kubernetes a partir da sua máquina local, acesse qualquer instância do tipo master,
e copie o conteúdo do arquivo `/etc/kubernetes/admin.conf` para dentro da sua máquina. Lembre-se: As instâncias
estão rodando em redes privadas, então para fazer o acesso utilizando AWS CLI e SSM você precisa ter o plugin do SSM configurado na sua máquina. 

```bash
$ aws ssm start-session --target <ANY_MASTER_INSTANCE_ID>
$ sudo su
$ cat /etc/kubernetes/admin.conf
```

Copie o resultado do `cat`, para o arquivo `/etc/kubernetes/admin.conf` na sua máquina local e lembre-se
de substituir o `DNS do NLB` por `127.0.0.1` e também adicionar o apontamento do endereço `127.0.0.1` para o `DNS do NLB` no arquivo `hosts` da sua máquina.

12.Para testar a conexão, abra um túnel e execute `kubectl get nodes`:

```bash
$ aws ssm start-session --target <ANY_MASTER_INSTANCE_ID> --document-name AWS-StartPortForwardingSession --parameters 'portNumber=6443,localPortNumber=6443'
$ export KUBECONFIG=/etc/kubernetes/admin.conf
$ kubectl get nodes
```
**Observação**: Caso queira revisar esse processo de conexão, reveja aula `Aula 33-Acesso Local e Port Forwarding`.

