#!/bin/sh

DNS_SERVER="${DNS_SERVER:-8.8.8.8}"

get_endpoint_host() {
    local conf="$1"
    grep -E "^Endpoint\s*=" "$conf" | head -1 | sed 's/.*=\s*\([^:]*\).*/\1/' | tr -d ' '
}

resolve_ips() {
    local host="$1"
    nslookup "$host" "$DNS_SERVER" 2>/dev/null | awk '/^Address: / && NR>2 {print $2}'
}

get_wg_endpoint_ip() {
    local iface="$1"
    wg show "$iface" dump 2>/dev/null | tail -n +2 | awk -F'\t' '{print $3}' | cut -d':' -f1 | head -1
}

check_and_restart() {
    local conf="$1"
    local iface=$(basename "$conf" .conf)
    local endpoint_host=$(get_endpoint_host "$conf")
    
    [ -z "$endpoint_host" ] && return
    
    local resolved_ips=$(resolve_ips "$endpoint_host")
    [ -z "$resolved_ips" ] && return
    
    local wg_ip=$(get_wg_endpoint_ip "$iface")
    [ -z "$wg_ip" ] && return
    
    local match=0
    for ip in $resolved_ips; do
        if [ "$ip" = "$wg_ip" ]; then
            match=1
            break
        fi
    done
    
    if [ $match -eq 0 ]; then
        echo "$(date): $iface endpoint $endpoint_host IP mismatch. WG: $wg_ip, DNS: $resolved_ips"
        wg-quick down "$iface" 2>/dev/null
        wg-quick up "$iface"
    fi
}

while true; do
    for conf in /config/wg_confs/*.conf; do
        [ -f "$conf" ] || continue
        check_and_restart "$conf"
    done
    sleep "${CHECK_INTERVAL:-60}"
done
