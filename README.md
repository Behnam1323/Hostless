# Hostless VLESS + XHTTP + Xray-core

Deploy-ready Docker project for Hostless Apps.

## Architecture

Client (v2rayNG) -> Hostless HTTPS/TLS -> Xray-core -> Internet

Transport: VLESS + XHTTP
Path: `/xhttp/`
TLS: terminated by Hostless HTTPS
Xray listens on Hostless-provided `PORT`.

This project does not use WebSocket, `/api/ws`, a Node.js TCP relay, or a fixed internal port.

## Deploy on Hostless

1. Put this repository on GitHub/GitLab/Bitbucket.
2. In Hostless create an **App** from the repository.
3. Select **Docker** as build system (or let `hostless.yaml` select Docker).
4. Do not manually set `PORT`; Hostless supplies it.
5. Optional: set `XRAY_UUID` to your own UUID.
6. Deploy and wait for the TCP health check to become healthy.
7. Open the generated HTTPS domain.

Hostless automatically provides HTTPS for the generated app domain.

## v2rayNG

After deployment use:

- Address: your Hostless domain, without `https://`
- Port: 443
- Protocol: VLESS
- UUID: value of `XRAY_UUID`
- Encryption: none
- Network: XHTTP
- Path: `/xhttp/`
- Mode: `auto`
- TLS: ON
- SNI: same as Hostless domain
- Flow: empty
- ALPN: leave client default unless Hostless/client documentation requires a specific value
- Host: normally leave empty for XHTTP; if your client exposes an HTTP Host field, use the Hostless domain

Do not use:

- WebSocket
- `/api/ws`
- gRPC
- XHTTP path `/xhttp` without the trailing slash if the client normalizes paths differently

## UUID

Default UUID:
`a9359e2d-3c7f-49c4-a4ea-f90249c5269a`

For security, change it in Hostless Environment Variables by setting `XRAY_UUID` to a UUID you control.

## Startup logs

The container prints PORT, XHTTP path, UUID, and—if `DOMAIN` is set—a ready VLESS URI. It also validates the generated Xray configuration before starting.

## Local Docker test

```bash
docker build -t hostless-vless-xhttp .
docker run --rm -p 8080:8080 -e PORT=8080 -e DOMAIN=localhost hostless-vless-xhttp
```

The container downloads a pinned Xray-core release during Docker build. The Dockerfile currently pins Xray-core `v26.9.9`.

## Important

Hostless must provide the public HTTPS endpoint. Xray itself is intentionally configured without TLS because TLS is terminated by Hostless's HTTPS routing layer.
