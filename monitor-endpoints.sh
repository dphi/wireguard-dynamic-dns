#!/bin/sh

while true; do
    for conf in /config/wg_confs/*.conf; do
        [ -f "$conf" ] || continue
        /usr/local/bin/reresolve-dns.sh "$conf"
    done
    sleep "${CHECK_INTERVAL:-30}"
done
