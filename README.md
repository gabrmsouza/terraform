# Terraform (HashiCorp)

É uma **ferramenta** (escrita em GO) open source de IAC (infraestructure as code) que automatiza o provisionamento de infraesturua em diversos providers (uma interface de conexão entre diversas clouds...). O terraform é instruido a provisionar a infraestrutura (criar os componentes como vpcs, subnets, gateways, servidores, dbs...) via arquivos de configuração.

A linguagem utilizada para definir os arquivos de configuração do terraform é a HCL (HashiCorp Configuration Language). A extensão para esses arquivos de configuração é .tf

## Idempotência

É uma forma de garantir que uma mesma tarefa não vai ser executada mais de uma vez ou um mesmo recurso não vai ser criado mais de uma vez. **O terraform por padrão é idempotênte**, ou seja, uma vez criado os componentes de infraestrutura, o terraform não vai cria-los novamente a cada execução dos arquivos de configuração e sim atualizados quando um componente tiver suas configurações alteradas.

### Imperativa

É uma forma de o terraform executar ação por ação, e a cada nova execução o terraform ira repetir as ações

### Declarativa

É uma forma de o terraform fazer um diff da infraestrutura para saber se provisiona ou não os componentes

## Terraform vs Ansible

- Ansible:
    - gerencia e automatiza configurações, instalações em vários host;
    - pode provisionar infraestrutura, mas não no mesmo nivel do terraform;

- Terraform:
    - provisona infraestrutura;
    - pode gerenciar e automatizar configurações, instalações mas não no mesmo nivel do ansible;

É possivel provisionar a infraestrutura (cluster k8s pode exemplo) com o terraform, e configurar os hosts utilizando o ansible.

__Ideal é utilizar os 2 em conjunto, pois um complementa o outro.__

## Gerenciamento de estado

Terraform usa um arquivo para armazenar o estado atual da infraestrutura provisionada, esse arquivo armazena tudo o que o terraform já fez, tipo um histórico. Quando necessário, ele usa esse arquivo para fazer um diff da infraestrutura (atual com a nova) para saber se atualiza ou não seu estado. Existem casos que o terraform precisa destruir e recriar um recurso para que seu estado seja atualizado.

Em alterações que um recurso precisa ser destruido, o terraform cria um backup, por segurança, do estado atual da infraestrutura, antes de aplicar as novas atualizações do recurso.

***Esse arquivo de estado do terraform é de extrema importancia, pois é nele que o terraform se baseia para saber o estado atual da infraestrutura. Se esse arquivo de estado for deletado, por exemplo, o terraform não vai conhecer mais o estado atual da infraestrutura e vai recriar todos os recursos novamente. É possivel deixar esse arquivo online (por exemplo em um s3) para trabalhar colaborativamente com o terraform***

Terraform exibe um plano de execução, de tudo o que ele vai fazer para provisionar a infraestrutura.

## Modulos

são agrupamentos de resources.

## Comandos

```bash
# esse comando inicializa um projeto terraform, instalando os provider se identificados
$ terraform init

---

# esse comando faz o terraform criar um plano de execução para a criação/atualização dos recursos, ou seja, é gerado um output com as ações que o terraform terá que fazer para que os recursos sejam criados/atualizados
$ terraform plan

---

# esse comando faz o terraform executar o plano criado após a execução do 'terraform plan'. Antes de executar de fato o plano, temos que dar o ok para o terraform.
$ terraform apply

---

# esse comando faz o terraform executar o plano criado após a execução do 'terraform plan', sem precisar do nosso ok.
$ terraform apply --auto-approve

---

# É possivel fazer o terraform ler uma variavel de ambiente, basta que a variavel tenha o prefixo TF_VAR_name
$ export TF_VAR_xpto="Hello World"
$ terraform apply

---

# esse comando faz o terraform receber a definição de uma variavel por linha de comando
$ terraform apply -var "xpto=Hello World"

---

# esse comando expecifica para o terraform o arquivo .tfvars
$ terraform apply -var-file xpto.tfvars

---

# esse comando remove todos os recursos criados pelo terraform
$ terraform destroy
```