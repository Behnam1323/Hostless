#!/bin/sh
set -eu

PORT="${PORT:-8080}"
UUID="${XRAY_UUID:-a9359e2d-3c7f-49c4-a4ea-f90249c5269a}"
WS_PATH="${XRAY_WS_PATH:-/api/ws}"
LOGLEVEL="${XRAY_LOGLEVEL:-warning}"

case "$WS_PATH" in
  /*) : ;;
  *) WS_PATH="/$WS_PATH" ;;
esac

case "$WS_PATH" in
  */) WS_PATH="${WS_PATH%/}" ;;
esac

case "$UUID" in
  ????????-????-????-????-????????????) : ;;
  *) echo "ERROR: XRAY_UUID is not a valid UUID: $UUID" >&2; exit 1 ;;
esac

CONFIG_FILE="/tmp/xray-config.json"

sed \
  -e "s|__PORT__|$PORT|g" \
  -e "s|__UUID__|$UUID|g" \
  -e "s|__WS_PATH__|$WS_PATH|g" \
  -e "s|__LOGLEVEL__|$LOGLEVEL|g" \
  /etc/xray/config.template.json > "$CONFIG_FILE"

echo "--- Hostless Xray WebSocket startup ---"
echo "PORT=$PORT"
echo "WS_PATH=$WS_PATH"
echo "UUID=$UUID"
if [ -n "${DOMAIN:-}" ]; then
  echo "VLESS_WS_URI=vless://${UUID}@${DOMAIN}:443?encryption=none&security=tls&type=ws&path=$(printf '%s' "$WS_PATH" | sed 's|/|%2F|g')&sni=${DOMAIN}#Hostless-WS"
else
  echo "DOMAIN is not set; supply the Hostless domain in v2rayNG."
fi

echo "Validating Xray configuration..."
xray run -test -config "$CONFIG_FILE"

echo "Starting Xray..."
exec xray run -config "$CONFIG_FILE"
