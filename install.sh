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
    MSG[check_root]="❌ Ce script doit être exécuté avec les privilèges root (sudo)."
    MSG[welcome]="🛡️  Installation des alertes Discord pour SSH et Fail2ban"
    MSG[ask_webhook]="Entrez l'URL de votre Webhook Discord : "
    MSG[invalid_webhook]="❌ URL invalide. Elle doit commencer par https://discord.com/api/webhooks/"
    MSG[installing]="⚙️  Configuration de SSH et Fail2ban en cours..."
    MSG[fail2ban]='🚨 **Fail2Ban** : Nouvelle attaque bloquée sur le serveur `$(hostname)` !\nL'\''IP `$IP` a été bannie par la règle `$JAIL`.'
    MSG[sshd]='✅ **Accès SSH Autorisé** sur `$(hostname)`\nL'\''utilisateur `$PAM_USER` s'\''est connecté avec succès depuis l'\''IP `$PAM_RHOST`.'
    MSG[done]="✅ Installation terminée ! Les notifications Discord sont actives."
else
    MSG[check_root]="❌ This script must be run as root (sudo)."
    MSG[welcome]="🛡️  Installing Discord alerts for SSH and Fail2ban"
    MSG[ask_webhook]="Enter your Discord Webhook URL: "
    MSG[invalid_webhook]="❌ Invalid URL. It must start with https://discord.com/api/webhooks/"
    MSG[installing]="⚙️  Configuring SSH and Fail2ban..."
    MSG[fail2ban]='🚨 **Fail2Ban**: New attack blocked on the server `$(hostname)`!\nIP `$IP` has been banned by the `$JAIL` jail.'
    MSG[sshd]='✅ **SSH Access Granted** on `$(hostname)`\nUser `$PAM_USER` successfully logged in from IP `$PAM_RHOST`.'
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

# --- 4. Configuration Fail2ban ---
mkdir -p /etc/fail2ban/scripts

# Note : On utilise 'EOF' entre guillemets simples pour ne pas interpréter $1, $2, etc.,
# puis on injecte les variables d'installation via sed.
cat << 'EOF' > /etc/fail2ban/scripts/discord-ban-alert.sh
#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Guillaume Sanchez

WEBHOOK_URL="__WEBHOOK_URL__"

IP="$1"
JAIL="$2"

JSON_PAYLOAD=$(cat <<INNER_EOF
{
  "content": "__MSG_FAIL2BAN__"
}
INNER_EOF
)

curl -s -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" "$WEBHOOK_URL"
EOF

# Injection sécurisée des variables (délimiteur | pour éviter les conflits avec les / de l'URL)
sed -i "s|__WEBHOOK_URL__|${WEBHOOK_URL}|g" /etc/fail2ban/scripts/discord-ban-alert.sh
sed -i "s|__MSG_FAIL2BAN__|${MSG[fail2ban]}|g" /etc/fail2ban/scripts/discord-ban-alert.sh
chmod +x /etc/fail2ban/scripts/discord-ban-alert.sh

cat << 'EOF' > /etc/fail2ban/action.d/discord-ban-alert.conf
[Definition]
actionban = /etc/fail2ban/scripts/discord-ban-alert.sh <ip> <name>
actionstart = 
actionstop = 
actioncheck = 
actionunban =
EOF

# Détection automatique du fichier de log SSH selon la distribution (Rocky/RHEL vs Debian/Ubuntu)
if [[ -f /var/log/secure ]]; then
    SSH_LOG_CONFIG="logpath = /var/log/secure"
elif [[ -f /var/log/auth.log ]]; then
    SSH_LOG_CONFIG="logpath = /var/log/auth.log"
else
    SSH_LOG_CONFIG="backend = systemd"
fi

cat << EOF > /etc/fail2ban/jail.d/sshd-discord-ban-alert.local
[sshd]
enabled = true
port    = ssh
filter  = sshd
${SSH_LOG_CONFIG}
maxretry = 3
bantime = 3600

action = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
         discord-ban-alert
EOF

systemctl restart fail2ban

# --- 5. Configuration SSH (PAM) ---
cat << 'EOF' > /usr/local/bin/discord-login.sh
#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Guillaume Sanchez

WEBHOOK_URL="__WEBHOOK_URL__"

if [ "$PAM_TYPE" != "open_session" ]; then
  exit 0
fi

JSON_PAYLOAD=$(cat <<INNER_EOF
{
  "content": "__MSG_SSHD__"
}
INNER_EOF
)

curl -s -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" "$WEBHOOK_URL"
EOF

sed -i "s|__WEBHOOK_URL__|${WEBHOOK_URL}|g" /usr/local/bin/discord-login.sh
sed -i "s|__MSG_SSHD__|${MSG[sshd]}|g" /usr/local/bin/discord-login.sh
chmod +x /usr/local/bin/discord-login.sh

# Ajout dans PAM uniquement si la ligne n'existe pas déjà
PAM_LINE="session optional pam_exec.so /usr/local/bin/discord-login.sh"
if ! grep -Fxq "$PAM_LINE" /etc/pam.d/sshd; then
    echo "$PAM_LINE" >> /etc/pam.d/sshd
fi

echo "${MSG[done]}"