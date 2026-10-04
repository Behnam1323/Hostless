FROM alpine:3.20 AS fetch
RUN apk add --no-cache curl tar ca-certificates
ARG XRAY_VERSION=26.9.30
RUN curl -fsSL "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64-v${XRAY_VERSION}.zip" -o /tmp/xray.zip \
 && mkdir -p /tmp/xray \
 && cd /tmp/xray \
 && unzip /tmp/xray.zip xray LICENSE geoip.dat geosite.dat 2>/dev/null || (apk add --no-cache unzip && unzip /tmp/xray.zip xray LICENSE geoip.dat geosite.dat)

FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata
COPY --from=fetch /tmp/xray/xray /usr/local/bin/xray
COPY --from=fetch /tmp/xray/geoip.dat /usr/local/share/xray/geoip.dat
COPY --from=fetch /tmp/xray/geosite.dat /usr/local/share/xray/geosite.dat
COPY xray/config.template.json /etc/xray/config.template.json
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENV XRAY_LOCATION_ASSET=/usr/local/share/xray
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
