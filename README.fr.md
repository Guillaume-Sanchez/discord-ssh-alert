# 🛡️ SSH & Fail2ban Discord Alerts

[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md)
[![Français](https://img.shields.io/badge/lang-Français-red.svg)](README.fr.md)

Un outil d'installation léger et automatisé permettant de déployer rapidement deux scripts de surveillance sur un serveur Linux afin de recevoir des notifications en temps réel sur un salon **Discord** via Webhook.

## Fonctionnalités

* **Alerte de connexion SSH :** Envoie une notification instantanée dès qu'un utilisateur ouvre une session SSH sur le serveur (utilisateur, adresse IP source, date/heure et nom d'hôte).
* **Alerte de bannissement Fail2ban :** Notifie automatiquement lorsqu'une adresse IP est bannie par une jail Fail2ban (IP bloquée, service concerné).
* **Déploiement rapide :** Script d'installation unique qui configure les hooks système et les actions Fail2ban sans intervention manuelle complexe.

## Prévisualisation



## Prérequis

* Un serveur Linux (Debian, Ubuntu, Rocky Linux, etc.)
* `openssh-server` installé et actif
* `fail2ban` installé et actif
* `curl` (pour l'envoi des requêtes vers l'API Discord)
* Une URL de **Webhook Discord**

## Installation

### Récupérer le Webhook Discord

* Allez dans votre serveur Discord.
* Cliquez sur le nom du serveur → Paramètres du serveur → Intégrations → Webhooks.
* Créez un nouveau webhook ou utilisez un existant.
* Copiez l'URL du webhook et collez-la dans (`$WEBHOOK_URL`) du script.

### Lancer le script d'installation

```bash
curl -sSL https://raw.githubusercontent.com/Guillaume-Sanchez/ssh-fail2ban-discord-alerts/refs/heads/main/install.sh | sudo bash
```

## License

Ce projet est distribué sous licence MIT. Voir le fichier LICENSE pour plus de détails.