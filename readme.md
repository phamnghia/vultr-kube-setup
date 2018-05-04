## Setup kubenetes cluster on VMs
---

### Prerequisite
* Terraform
* 2 VMs that added ssh public key. One master and one client node

### Installation
* Step 1: create file ```env.auto.tfvars``` with those variables:
	* master_ip = "[Master IP]"
	* node_ip = "[Node IP]"
	* private_key_file = "[Path to ssh private key file. Ex: ~/.ssh/dev_rsa]"
* Step 2: ```terraform init```
* Step 3: ```terraform apply -auto-approve```