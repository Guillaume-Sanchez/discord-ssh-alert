#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Guillaume Sanchez

if [ "$PAM_TYPE" != "open_session" ]; then
  exit 0
fi

WEBHOOK_URL="__WEBHOOK_URL__"

JSON_PAYLOAD=$(cat <<EOF
{
  "content": "✅ **SSH Access Granted** on \`$(hostname)\`\nUser \`$PAM_USER\` successfully logged in from IP \`$PAM_RHOST\`."
}
EOF
)

curl -s -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" $WEBHOOK_URL
