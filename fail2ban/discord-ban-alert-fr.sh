#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Guillaume Sanchez

WEBHOOK_URL="__WEBHOOK_URL__"

IP=$1
JAIL=$2

JSON_PAYLOAD=$(cat <<EOF
{
  "content": "🚨 **Fail2Ban** : Nouvelle attaque bloquée sur le serveur \`$(hostname)\` !\nL'IP \`$IP\` a été bannie par la règle \`$JAIL\`."
}
EOF
)

# Envoi de la requête silencieuse (-s) pour ne pas polluer les logs Fail2Ban
curl -s -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" $WEBHOOK_URL
