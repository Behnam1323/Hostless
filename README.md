# Hostless VLESS + WebSocket + Xray

A Docker-based VLESS server designed for Hostless Apps.

## Architecture

v2rayNG -> HTTPS/TLS on Hostless -> WebSocket /api/ws -> Xray VLESS -> Freedom -> Internet

TLS is terminated by Hostless. Xray listens on the internal `PORT` supplied by Hostless and therefore does not need a certificate inside the container.

## Hostless requirements

- Docker build
- `PORT` is supplied by Hostless
- Xray binds to `0.0.0.0`
- TCP health check
- one replica

## Environment variables

- `XRAY_UUID` — VLESS UUID; default is the UUID shown in QUICK-START.txt.
- `XRAY_WS_PATH` — WebSocket path; default `/api/ws`.
- `XRAY_LOGLEVEL` — default `warning`; use `info` for troubleshooting.
- `DOMAIN` — optional; only used to print a ready VLESS URI in startup logs.

## v2rayNG

Address: the Hostless app domain
Port: 443
Protocol: VLESS
Network: WebSocket
Path: `/api/ws`
TLS: enabled
SNI/Host: the Hostless app domain
ALPN: `http/1.1`
Flow: empty

## Important

Do not configure `/xhttp/` or XHTTP with this image. This image is WebSocket-only.
