#!/bin/bash

# Remplacez par l'URL de votre Webhook
WEBHOOK_URL="__WEBHOOK_URL__"

IP=$1
JAIL=$2

# Formatage du message envoyé sur Discord
JSON_PAYLOAD=$(cat <<EOF
{
  "content": "__MSG_FAIL2BAN__"
}
EOF
)

# Envoi de la requête silencieuse (-s) pour ne pas polluer les logs Fail2Ban
curl -s -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" $WEBHOOK_URL
