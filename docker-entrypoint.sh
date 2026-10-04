#!/bin/sh
set -eu

PORT="${PORT:-8080}"
UUID="${XRAY_UUID:-a9359e2d-3c7f-49c4-a4ea-f90249c5269a}"
PATH_XHTTP="${XRAY_XHTTP_PATH:-/xhttp/}"
MODE="${XRAY_XHTTP_MODE:-auto}"
LOGLEVEL="${XRAY_LOGLEVEL:-warning}"

case "$PATH_XHTTP" in
  /*) : ;;
  *) PATH_XHTTP="/$PATH_XHTTP" ;;
esac
case "$PATH_XHTTP" in
  */) : ;;
  *) PATH_XHTTP="$PATH_XHTTP/" ;;
esac

# Basic validation; prevents accidental startup with an invalid UUID.
case "$UUID" in
  ????????-????-????-????-????????????) : ;;
  *) echo "ERROR: XRAY_UUID is not a valid UUID: $UUID" >&2; exit 1;;
esac

CONFIG_FILE="/tmp/xray-config.json"

sed \
  -e "s|__PORT__|$PORT|g" \
  -e "s|__UUID__|$UUID|g" \
  -e "s|__XHTTP_PATH__|$PATH_XHTTP|g" \
  -e "s|__XHTTP_MODE__|$MODE|g" \
  -e "s|__LOGLEVEL__|$LOGLEVEL|g" \
  /etc/xray/config.template.json > "$CONFIG_FILE"

# Optional startup information. DOMAIN is supplied by the user/Hostless environment.
echo "--- Hostless Xray startup ---"
echo "PORT=$PORT"
echo "XHTTP_PATH=$PATH_XHTTP"
echo "XHTTP_MODE=$MODE"
echo "UUID=$UUID"
if [ -n "${DOMAIN:-}" ]; then
  echo "VLESS_XHTTP_URI=vless://${UUID}@${DOMAIN}:443?encryption=none&security=tls&type=xhttp&path=$(printf '%s' "$PATH_XHTTP" | sed 's|/|%2F|g')&mode=${MODE}&sni=${DOMAIN}#Hostless-XHTTP"
else
  echo "DOMAIN is not set; VLESS URI will be shown after DOMAIN is supplied."
fi

echo "Validating Xray configuration..."
xray run -test -config "$CONFIG_FILE"

echo "Starting Xray..."
exec xray run -config "$CONFIG_FILE"
