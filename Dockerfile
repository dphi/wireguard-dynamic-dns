FROM ghcr.io/linuxserver/wireguard:1.0.20250521-r0-ls88

COPY monitor-endpoints.sh /usr/local/bin/monitor-endpoints.sh
COPY s6-monitor-endpoints /etc/services.d/monitor-endpoints
RUN chmod +x /usr/local/bin/monitor-endpoints.sh && \
    chmod +x /etc/services.d/monitor-endpoints/run
