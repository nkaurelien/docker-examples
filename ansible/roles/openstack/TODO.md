# TODO - Intégration OpenStack & OpenStack-Ansible

Feuille de route pour l'évaluation et l'implémentation d'OpenStack.

---

## Phase 1 : Étude de faisabilité & Architecture
- [ ] Définir la cible d'hébergement :
  - [ ] Machine dédiée vs Hyperviseur (Proxmox VE / KVM) vs Cohabitation.
  - [ ] Évaluer les besoins réels en IaaS (VMs classiques vs conteneurs K3s).
- [ ] Analyser l'alternative **KubeVirt** sur le cluster K3s existant pour la gestion des VMs directement depuis Kubernetes.
- [ ] Évaluer **MicroStack / Sunbeam** (Canonical) comme alternative plus légère à OpenStack-Ansible en mode mono-nœud.

---

## Phase 2 : Prérequis & Réseau (Si OpenStack-Ansible est retenu)
- [ ] Configuration des interfaces et bridges Linux requis par OSA :
  - [ ] `br-mgmt` (réseau de gestion OpenStack)
  - [ ] `br-vxlan` (réseau overlay pour le trafic tenant Neutron)
  - [ ] `br-vlan` (réseau provider / accès externe)
- [ ] Vérifier la compatibilité du kernel hôte et de la distribution (Ubuntu LTS recommandée).
- [ ] Prévoir au moins 20 à 25 Go de RAM dédiée et 100 Go d'espace disque libre pour LXC/libvirt.

---

## Phase 3 : Déploiement All-In-One (AIO)
- [ ] Cloner et préparer `openstack-ansible` :
  ```bash
  git clone https://github.com/openstack/openstack-ansible /opt/openstack-ansible
  cd /opt/openstack-ansible
  # Checkout de la branche stable ciblée (ex: 2024.1 / 2024.2)
  ```
- [ ] Exécuter le bootstrap script :
  ```bash
  scripts/bootstrap-ansible.sh
  scripts/bootstrap-aio.sh
  ```
- [ ] Lancer les playbooks principaux OSA :
  - [ ] `setup-hosts.yml` (création des conteneurs LXC et bridges)
  - [ ] `setup-infrastructure.yml` (MariaDB, RabbitMQ, Memcached)
  - [ ] `setup-openstack.yml` (Keystone, Glance, Nova, Neutron, Horizon)

---

## Phase 4 : Post-installation & Intégration
- [ ] Vérifier l'accès au tableau de bord Horizon (HTTPS).
- [ ] Configurer les réseaux virtuels Neutron, images de base (CirrOS, Ubuntu Cloud Images) et flavors.
- [ ] Tester le lancement d'une instance VM de test.
- [ ] (Optionnel) Déployer K3s à l'intérieur d'instances OpenStack via Terraform ou `k3s-io/k3s-ansible`.
