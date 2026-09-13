# Ntfy Push Notification Service Credentials & Configuration

- **Service Name**: ntfy
- **URL**: `https://ntfy.kamitbrains.fr`
- **Healthcheck URL**: `https://ntfy.kamitbrains.fr/v1/health`
- **Admin Password File**: `.secrets/ntfy-admin-password`
- **Topic File**: `.secrets/ntfy-topic`
- **Base URL**: `https://ntfy.kamitbrains.fr`
- **Pub/Sub Topic Example**: `curl -d "Test notification" https://ntfy.kamitbrains.fr/$(cat .secrets/ntfy-topic)`

## 🔄 Rotation du nom de topic secret :
Pour renouveler ou pivoter le nom de topic en cas de besoin :
1. Mettre à jour le fichier secret `.secrets/ntfy-topic` avec un nouveau code prononçable :
   ```bash
   echo "alerts-<nouveau-code-prononcable>" > .secrets/ntfy-topic
   ```
2. Re-générer / mettre à jour l'entrée `Ntfy Push Secret Topic` dans `.secrets/passbolt_import_secrets.csv`.
3. Re-déployer la stack Uptime Kuma pour appliquer le nouveau canal de notification :
   ```bash
   ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags "ntfy,uptime-kuma"
   ```
4. Réabonner l'application mobile ou les clients Ntfy au nouveau topic.
