# Discord Ssh Alert

[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md)
[![Français](https://img.shields.io/badge/lang-Français-red.svg)](README.fr.md)

Un outil d'installation léger et automatisé permettant de déployer rapidement deux scripts de surveillance sur un serveur Linux afin de recevoir des notifications en temps réel sur un salon **Discord** via Webhook.

## Fonctionnalités

* **Alerte de connexion SSH :** Envoie une notification instantanée dès qu'un utilisateur ouvre une session SSH sur le serveur (utilisateur, adresse IP source, date/heure et nom d'hôte).
* **Alerte de bannissement Fail2ban :** Notifie automatiquement lorsqu'une adresse IP est bannie par une jail Fail2ban (IP bloquée, service concerné).
* **Déploiement rapide :** Script d'installation unique qui configure les hooks système et les actions Fail2ban sans intervention manuelle complexe.

## Prérequis

* Un serveur Linux (Debian, Ubuntu, Rocky Linux, etc.)
* `openssh-server` installé et actif
* `fail2ban` installé et actif
* `curl` (pour l'envoi des requêtes vers l'API Discord)
* Une URL de **Webhook Discord**

## Installation

```bash
git clone [https://github.com/Guillaume-Sanchez/discord-ssh-alert.git](https://github.com/Guillaume-Sanchez/discord-ssh-alert.git)
cd discord-ssh-alert
chmod +x install.sh
sudo ./install.sh
```

## License

Ce projet est distribué sous licence MIT. Voir le fichier LICENSE pour plus de détails.