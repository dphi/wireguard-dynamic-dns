FROM ghcr.io/linuxserver/wireguard:1.0.20260223-r0-ls127@sha256:e2f655e1956a6db476bc879bf721f3f8bfed49c6d8fbcf39495d7ecb991d8228

COPY monitor-endpoints.sh /usr/local/bin/monitor-endpoints.sh
COPY reresolve-dns.sh /usr/local/bin/reresolve-dns.sh
COPY s6-monitor-endpoints /etc/services.d/monitor-endpoints
RUN chmod +x /usr/local/bin/monitor-endpoints.sh && \
    chmod +x /usr/local/bin/reresolve-dns.sh && \
    chmod +x /etc/services.d/monitor-endpoints/run
