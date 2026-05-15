#!/bin/bash
UUID=$(cat /home/vscode/uuid.txt)

# Try to get the public Codespace domain for port 443
# Method: use gh cli to get browseUrl of port 443
if command -v gh &> /dev/null && gh auth status &> /dev/null; then
    DOMAIN=$(gh codespace ports --json browseUrl,sourcePort | jq -r '.[] | select(.sourcePort == 443) | .browseUrl' | sed 's|https://||' | sed 's|/.*||')
    if [ -n "$DOMAIN" ]; then
        HOST=$DOMAIN
    else
        # fallback: construct from environment
        if [ -n "$CODESPACE_NAME" ] && [ -n "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN" ]; then
            HOST="${CODESPACE_NAME}-${CODESPACE_ID}-443.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
        else
            HOST=$(curl -s ifconfig.me)  # last resort: IP
        fi
    fi
else
    # If gh not available, try to get from environment or IP
    if [ -n "$CODESPACE_NAME" ] && [ -n "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN" ]; then
        HOST="${CODESPACE_NAME}-${CODESPACE_ID}-443.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
    else
        HOST=$(curl -s ifconfig.me)
    fi
fi

echo ""
echo "====================================="
echo "🔗 NikVPN - VLESS xHTTP Connection Link"
echo "====================================="
echo "vless://$UUID@$HOST:443?encryption=none&security=tls&sni=$HOST&host=$HOST&fp=chrome&allowInsecure=1&type=xhttp&mode=packet-up&path=%2F#nikvpn-codespace"
echo ""
echo "✅ If connection fails, try changing 'allowInsecure=1' to 'allowInsecure=0' (if your client supports it)."
echo "✅ Make sure port 443 is PUBLIC in the PORTS tab (check the 'Forwarded Address' column)."
echo "====================================="
