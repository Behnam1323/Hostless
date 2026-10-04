FROM alpine:3.22
ARG XRAY_VERSION=26.9.30
RUN apk add --no-cache ca-certificates curl unzip bash jq openssl \
 && mkdir -p /usr/local/share/xray /etc/xray \
 && curl -fsSL "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64.zip" -o /tmp/xray.zip \
 && unzip -q /tmp/xray.zip -d /usr/local/share/xray \
 && mv /usr/local/share/xray/xray /usr/local/bin/xray \
 && chmod +x /usr/local/bin/xray \
 && rm -rf /tmp/xray.zip /usr/local/share/xray
COPY xray/config.template.json /etc/xray/config.template.json
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY README.md /README.md
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENV XRAY_UUID=a9359e2d-3c7f-49c4-a4ea-f90249c5269a \
    XRAY_XHTTP_PATH=/xhttp/ \
    XRAY_XHTTP_MODE=auto \
    XRAY_LOGLEVEL=warning
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
