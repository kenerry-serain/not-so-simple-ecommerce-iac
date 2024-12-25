# Ferramental

AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html <br>
Terraform: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli <br>
Ansible: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

# Not So Simple Ecommerce (Terraform)

Para melhor entendimento, minha recomendação é assistir as aulas antes de realizar a execução do código deste repositório na sua conta AWS para melhor entendimento do que está provisionando.

Antes de realizar o deployment das stacks, primeiramente é necessário realizar a configuração de uma Role, pois este repositório não utiliza de credenciais hard coded, para realizar a criação de uma role na sua conta AWS, execute:

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
                "sts:ExternalId": "f2ed091d-8d7d-46cb-be56-fb349d502cfb"
            }
        }
    }]
}'

```
Sendo que `f2ed091d-8d7d-46cb-be56-fb349d502cfb` significa uma string qualquer randômica como `bbe2a601-5f8c-41f8-91f2-ec734456ad4b`.

Agora anexe permissões administrativas a role criada executando o comando:

```bash
$    aws iam attach-role-policy \
        --role-name DevOpsNaNuvemRole \
        --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

Realize a substituição da string `arn:aws:iam::<AWS_ACCOUNT_ID>:role/DevOpsNaNuvemRole-9db671b2-c6ce-460c-9eb0-f27e903d0f9a` nos arquivos terraform (.tf) do repositório pelo valor correto executando o comando:

```bash
$ find . -type f -name "*.tf" -exec sed -i 's|arn:aws:iam::<AWS_ACCOUNT_ID>:role/DevOpsNaNuvemRole-9db671b2-c6ce-460c-9eb0-f27e903d0f9a|arn:aws:iam::<YOUR_ACCOUNT>:role/DevOpsNaNuvemRole|g' {} +
```

Realize a substituição da string `f2ed091d-8d7d-46cb-be56-fb349d502cfb` nos arquivos terraform (.tf) do repositório pelo valor verdadeiro `<YOUR_REAL_EXTERNAL_ID>` executando o comando:

```bash
$ find . -type f -name "*.tf" -exec sed -i 's|f2ed091d-8d7d-46cb-be56-fb349d502cfb|<YOUR_REAL_EXTERNAL_ID>|g' {} +
```

Execute primeiramente a criação da stack `backend`, para realizar a criação do backend remoto, que é composto de um bucket S3 para remote file state storage a uma tabela no Dynamo para state locking handling:

```bash
$ cd ./terraform/backend && terraform init && terraform apply -auto-approve
```

Agora realize o deployment da stack `networking`, pois é a base para todas as outras executando o comando::

```bash
$ cd ./terraform/networking && terraform init && terraform apply -auto-approve
```

Para fazer o deployment da stack `server`, execute: 

```bash
$ cd ./terraform/server && terraform init && terraform apply -auto-approve
```

Para fazer o deployment da stack `serverless`, execute: 

```bash
$ cd ./terraform/serverless && terraform init && terraform apply -auto-approve
```
Observação: Garanta que o arquivo index.js exista dentro da pasta build,
caso precise atualizar o código lembre-se de transpilar o arquivo index.ts para o index.js utilizando o `tsc` - conforme aprendido no módulo 05.

# Not So Simple Ecommerce (Ansible)

Para melhor entendimento, minha recomendação é assistir as aulas antes de realizar a execução do código deste repositório na sua conta AWS para melhor entendimento do que está provisionando.

Também fazemos a utilização de credenciais AWS para interagir com a API da AWS de dentro dos playbooks, então realize a substituição da string `<YOUR_ACCESS_KEY>` e da string `<YOUR_SECRET_ACCESS_KEY>` pelos respectivos valores verdadeiros `<YOUR_SECRET_ACCESS_KEY>` e `<YOUR_REAL_SECRET_ACCESS_KEY>` e também da string `<YOUR_AWS_PROFILE>` pelo valor verdadeiro `<YOUR_REAL_AWS_PROFILE>` nos arquivos YAMLs (.yml) executando o comando:

```bash
$ find . -type f -name "*.yml" -exec sed -i 's|<YOUR_ACCESS_KEY>|<YOUR_REAL_ACCESS_KEY>|g' {} + &&
$ find . -type f -name "*.yml" -exec sed -i 's|<YOUR_SECRET_ACCESS_KEY>|<YOUR_REAL_SECRET_ACCESS_KEY>|g' {} + &&
$ find . -type f -name "*.yml" -exec sed -i 's|<YOUR_AWS_PROFILE>|<YOUR_REAL_SECRET_ACCESS_KEY>|g' {} +
```

Realize a execução do comando `pwd` no diretório raiz onde clonou este projeto e copie todo valor antes do diretório `not-so-simple-ecommerce-iac`, substitua a string `<YOUR_REPOSITORY_PATH>` nos arquivos YAMLs (.yml) por este valor no lugar da string `<YOUR_REAL_REPOSITORY_PATH>` executando o comando:

```bash
$ find . -type f -name "*.yml" -exec sed -i 's|<YOUR_REPOSITORY_PATH>|<YOUR_REAL_REPOSITORY_PATH>|g' {} +
```

Para executar a criação do Cluster Kubernetes nas instâncias provisionads pela stack `server`, execute:

```bash
$ cd ./ansible && ansible-playbook -i production.aws_ec2.yml site.yml --ask-become-pass OU
$ export BECOME_PASSWORD="<YOUR_PASSWORD>"
$ ansible-playbook -i production.aws_ec2.yml site.yml --extra-vars "ansible_become_password=$BECOME_PASSWORD"
```