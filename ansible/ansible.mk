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
	@echo "  make ansible-deploy         - Execute main site.yml playbook"
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

# Run main playbook
ansible-deploy:
	@echo "Executing main Ansible playbook..."
	@cd $(ANSIBLE_DIR) && ansible-playbook $(ANSIBLE_PLAYBOOK)

# Install requirements from Galaxy
ansible-galaxy-install:
	@echo "Installing Galaxy roles from requirements.yml..."
	@cd $(ANSIBLE_DIR) && ansible-galaxy role install -r requirements.yml --force
