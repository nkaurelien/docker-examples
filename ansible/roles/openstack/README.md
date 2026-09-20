# Role Ansible : OpenStack (openstack-ansible)

Ce rôle prépare et documente l'intégration future du projet officiel [OpenStack-Ansible (OSA)](https://github.com/openstack/openstack-ansible).

## Contexte & Décision d'Architecture

- **Statut actuel** : **En attente / Étude**. Le serveur Acemagic K1 mini héberge actuellement le cluster **K3s (Kubernetes)** déployé avec `k3s-io/k3s-ansible`.
- **Ressources K1 Mini** : 4 cœurs / 8 vCPU, 32 Go RAM, 1 To SSD.
- **Raison du report** : OpenStack-Ansible (mode AIO) déploie entre 15 et 25 conteneurs système LXC (MariaDB/Galera, RabbitMQ, Keystone, Glance, Nova, Neutron, Horizon) nécessitant 16 à 24 Go de RAM et manipulant de nombreux ponts réseau Linux et règles netfilter. Une cohabitation directe sans hyperviseur sur le même OS risquerait de saturer les ressources et de créer des conflits réseau avec les pods et Traefik de K3s.

## Modes de Déploiement Envisagés

1. **Option A (Recommandée à terme)** : K3s hébergé au sein d'instances VMs OpenStack (IaaS/PaaS standard).
2. **Option B (Homelab avec Hyperviseur)** : Virtualisation sous Proxmox VE avec une VM dédiée pour OpenStack AIO et une VM/LXC dédiée pour K3s.
3. **Option C (Alternative légère Kubernetes)** : Déployer **KubeVirt** sur K3s pour gérer des VMs sans la complexité d'OpenStack.

## Références Utiles

- [Dépôt GitHub openstack-ansible](https://github.com/openstack/openstack-ansible)
- [Documentation OpenStack-Ansible Quickstart](https://docs.openstack.org/openstack-ansible/latest/user/aio/quickstart.html)
- [OpenStack Deployment Guide](https://docs.openstack.org/project-deploy-guide/openstack-ansible/latest/)
