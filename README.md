# 🛡️ SSH & Fail2ban Discord Alerts

[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md)
[![Français](https://img.shields.io/badge/lang-Français-red.svg)](README.fr.md)

A lightweight, automated installation tool that deploys two monitoring scripts on a Linux server to receive real-time **Discord** notifications via Webhook.

## Features

* **SSH Login Alert:** Sends an instant notification whenever a user opens an SSH session on the server (username, source IP address, timestamp, and hostname).
* **Fail2ban Ban Alert:** Automatically notifies when an IP address is banned by a Fail2ban jail (blocked IP, triggered service/jail).
* **Fast Deployment:** Single installation script that configures system hooks and Fail2ban actions without complex manual setup.

## Preview



## Prerequisites

* A Linux server (Debian, Ubuntu, Rocky Linux, etc.)
* `openssh-server` installed and running
* `fail2ban` installed and running
* `curl` (to send HTTP requests to the Discord API)
* A **Discord Webhook** URL

## Installation

### Get your Discord Webhook

* Go to your Discord server.
* Click on the server name → Server Settings → Integrations → Webhooks.
* Create a new webhook or use an existing one.
* Copy the webhook URL and paste it when prompted by the script (`$WEBHOOK_URL`).

### Run the installation script

```bash
curl -sSL https://raw.githubusercontent.com/Guillaume-Sanchez/ssh-fail2ban-discord-alerts/refs/heads/main/install.sh | sudo bash
```

## Licence

This project is licensed under the MIT License. See the LICENSE file for details.