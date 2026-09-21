# Ansible Operations Makefile Module
# Included in main Makefile via -include ansible/ansible.mk

.PHONY: ansible-help ansible-ping ansible-syntax ansible-inventory ansible-deploy ansible-galaxy-install

ANSIBLE_DIR ?= ansible
ANSIBLE_PLAYBOOK ?= site.yml
ANSIBLE_INVENTORY ?= inventory.yml

ansible-help:
	@echo "Ansible Commands:"
	@echo "  make ansible-ping           - Test SSH connectivity to inventory hosts"
	@echo "  make ansible-syntax         - Verify syntax of Ansible playbooks"
	@echo "  make ansible-inventory      - Display parsed Ansible inventory JSON"
	@echo "  make ansible-deploy         - Execute Ansible playbook (all roles)"
	@echo "  make ansible-deploy TAGS=\"homepage\" - Execute playbook targeting specific tags"
	@echo "  make ansible-deploy SKIP_TAGS=\"common\" - Execute playbook skipping specified tags"
	@echo "  make ansible-galaxy-install - Install external Galaxy roles from requirements.yml"
	@echo ""

# Test SSH connection to all hosts
ansible-ping:
	@echo "Pinging all hosts in Ansible inventory..."
	@cd $(ANSIBLE_DIR) && ansible all -m ping

# Check syntax of the main playbook
ansible-syntax:
	@echo "Checking syntax of Ansible playbooks..."
	@cd $(ANSIBLE_DIR) && ansible-playbook $(ANSIBLE_PLAYBOOK) --syntax-check

# List inventory hosts and variables
ansible-inventory:
	@echo "Listing Ansible inventory..."
	@cd $(ANSIBLE_DIR) && ansible-inventory -i $(ANSIBLE_INVENTORY) --list

# Run main playbook (supports TAGS="homepage" or SKIP_TAGS="common")
ansible-deploy:
	@echo "Executing Ansible playbook..."
	@cd $(ANSIBLE_DIR) && ansible-playbook $(ANSIBLE_PLAYBOOK) $(if $(TAGS),--tags "$(TAGS)",) $(if $(SKIP_TAGS),--skip-tags "$(SKIP_TAGS)",)

# Install requirements from Galaxy
ansible-galaxy-install:
	@echo "Installing Galaxy roles from requirements.yml..."
	@cd $(ANSIBLE_DIR) && ansible-galaxy role install -r requirements.yml --force
	@cd $(ANSIBLE_DIR) && ansible-galaxy collection install -r requirements.yml --force

# --- K3s Cluster Targets (K1 Mini) ---
.PHONY: k3s-deploy k3s-reset k3s-status k3s-airgap-prep

k3s-airgap-prep:
	@echo "Preparing Air-Gap artifacts for K3s..."
	@$(ANSIBLE_DIR)/scripts/prepare-airgap.sh v1.31.12+k3s1 amd64

k3s-deploy:
	@./scripts/banner.py "K3S DEPLOY" "Deploying K3s on K1 Mini (192.168.0.205)" slant cyan
	@cd $(ANSIBLE_DIR) && ansible-playbook -i k3s-io-inventory.yml k3s-io-deploy.yml

k3s-reset:
	@./scripts/banner.py "K3S RESET" "Teardown & Clean K3s on K1 Mini" slant yellow
	@cd $(ANSIBLE_DIR) && ansible-playbook -i k3s-io-inventory.yml k3s-io-reset.yml

k3s-status:
	@./scripts/banner.py "K3S STATUS" "Acemagic K1 Mini • Kubernetes v1.31.12" slant green
	@echo "=== K3s Nodes ==="
	@kubectl --context k3s-ansible get nodes -o wide
	@echo "\n=== K3s Pods ==="
	@kubectl --context k3s-ansible get pods -A
