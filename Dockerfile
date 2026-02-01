FROM ghcr.io/linuxserver/wireguard:latest

COPY monitor-endpoints.sh /usr/local/bin/monitor-endpoints.sh
COPY reresolve-dns.sh /usr/local/bin/reresolve-dns.sh
COPY s6-monitor-endpoints /etc/services.d/monitor-endpoints
RUN chmod +x /usr/local/bin/monitor-endpoints.sh && \
    chmod +x /usr/local/bin/reresolve-dns.sh && \
    chmod +x /etc/services.d/monitor-endpoints/run
