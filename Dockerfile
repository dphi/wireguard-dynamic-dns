FROM ghcr.io/linuxserver/wireguard:latest

COPY monitor-endpoints.sh /usr/local/bin/monitor-endpoints.sh
COPY s6-monitor-endpoints /etc/services.d/monitor-endpoints
RUN chmod +x /usr/local/bin/monitor-endpoints.sh && \
    chmod +x /etc/services.d/monitor-endpoints/run
