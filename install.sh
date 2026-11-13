#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Guillaume Sanchez

set -e

# --- 1. Gestion de la langue ---
APP_LANG=""

for arg in "$@"; do
    case $arg in
        --fr|--french|-fr)
            APP_LANG="fr"
            ;;
        --en|--english|-en)
            APP_LANG="en"
            ;;
    esac
done

if [[ -z "$APP_LANG" ]]; then
    echo "Select language / Choisissez la langue :"
    echo "1) English (default)"
    echo "2) Français"
    read -rp "> " lang_choice < /dev/tty
    if [[ "$lang_choice" == "2" || "$lang_choice" == "fr" ]]; then
        APP_LANG="fr"
    else
        APP_LANG="en"
    fi
fi

# --- 2. Dictionnaire de traductions ---
declare -A MSG

if [[ "$APP_LANG" == "fr" ]]; then
    MSG[check_root]="Ce script doit être exécuté avec les privilèges root (sudo)."
    MSG[welcome]="Installation des alertes Discord pour SSH et Fail2ban"
    MSG[ask_webhook]="Entrez l'URL de votre Webhook Discord : "
    MSG[invalid_webhook]="URL invalide. Elle doit commencer par https://discord.com/api/webhooks/"
    MSG[installing]="Configuration de SSH et Fail2ban en cours..."
    MSG[fail2ban]='  🚨 **Fail2Ban** : Nouvelle attaque bloquée sur le serveur \`$(hostname)\` !\nL IP \`$IP\` a été bannie par la règle \`$JAIL\`.'
    MSG[sshd]='✅ **Accès SSH Autorisé** sur \`$(hostname)\`\nL utilisateur \`$PAM_USER\` s est connecté avec succès depuis l IP \`$PAM_RHOST\`.'
    MSG[done]="✅ Installation terminée ! Les notifications Discord sont actives."
else
    MSG[check_root]="This script must be run as root (sudo)."
    MSG[welcome]="Installing Discord alerts for SSH and Fail2ban"
    MSG[ask_webhook]="Enter your Discord Webhook URL: "
    MSG[invalid_webhook]="Invalid URL. It must start with https://discord.com/api/webhooks/"
    MSG[installing]="Configuring SSH and Fail2ban..."
    MSG[fail2ban]='🚨 **Fail2Ban**: New attack blocked on the server $(hostname) !\nIP `$IP` has been banned by the `$JAIL` jail.'
    MSG[sshd]='✅ **SSH Access Granted** on \`$(hostname)\`\nUser \`$PAM_USER\` successfully logged in from IP \`$PAM_RHOST\`.'
    MSG[done]="✅ Installation complete! Discord notifications are now active."
fi

# --- 3. Exécution du script ---
if [[ $EUID -ne 0 ]]; then
   echo "${MSG[check_root]}"
   exit 1
fi

echo "----------------------------------------------------"
echo "${MSG[welcome]}"
echo "----------------------------------------------------"

read -rp "${MSG[ask_webhook]}" WEBHOOK_URL < /dev/tty

if [[ ! "$WEBHOOK_URL" =~ ^https://(canary\.|ptb\.)?discord(app)?\.com/api/webhooks/ ]]; then
    echo "${MSG[invalid_webhook]}"
    exit 1
fi

echo "${MSG[installing]}"

mkdir -p /etc/fail2ban/scripts
cd /etc/fail2ban/scripts

cat << EOF > discord-ban-alert.sh
#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Guillaume Sanchez

WEBHOOK_URL="$WEBHOOK_URL"

IP=$1
JAIL=$2

JSON_PAYLOAD=$(cat <<EOF
{
  "content": "${MSG[fail2ban]}"
}
EOF
)
curl -s -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" $WEBHOOK_URL
EOF

cd /etc/fail2ban/action.d
cat <<EOF > discord-ban-alert.conf
[Definition]
actionban = /etc/fail2ban/scripts/discord-ban-alert.sh <ip> <name>
actionstart = 
actionstop = 
actioncheck = 
actionunban =
EOF

cd /etc/fail2ban/jail.d
cat << 'EOF' > sshd-discord-ban-alert.local
[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = /var/log/secure
maxretry = 3
bantime = 3600

action = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
         discord
EOF

systemctl restart fail2ban

cd /usr/local/bin/

cat << EOF > discord-login.sh
#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Guillaume Sanchez

WEBHOOK_URL="$WEBHOOK_URL"

if [ "$PAM_TYPE" != "open_session" ]; then
  exit 0
fi

JSON_PAYLOAD=$(cat <<EOF
{
  "content": "${MSG[sshd]}"
}
EOF
)
curl -s -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" $WEBHOOK_URL
EOF

echo session optional pam_exec.so /usr/local/bin/discord-login.sh >> /etc/pam.d/sshd

echo "${MSG[done]}"