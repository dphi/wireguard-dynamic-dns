#!/bin/sh

DNS_SERVER="${DNS_SERVER:-8.8.8.8}"

get_endpoint_host() {
    local conf="$1"
    grep -E "^Endpoint\s*=" "$conf" | head -1 | sed 's/.*=\s*\([^:]*\).*/\1/' | tr -d ' '
}

resolve_ips() {
    local host="$1"
    nslookup "$host" "$DNS_SERVER" 2>/dev/null | awk '/^Address:/ {if (NR>2) print $2}' | grep -E '^[0-9a-f:.]+$'
}

get_wg_endpoint_ip() {
    local iface="$1"
    wg show "$iface" dump 2>/dev/null | tail -n +2 | awk -F'\t' '{print $3}' | head -1 | sed 's/^\[//;s/\]:[0-9]*$//;s/:[0-9]*$//'
}

get_wg_peer_pubkey() {
    local iface="$1"
    wg show "$iface" dump 2>/dev/null | tail -n +2 | awk -F'\t' '{print $1}' | head -1
}

get_endpoint_port() {
    local conf="$1"
    grep -E "^Endpoint\s*=" "$conf" | head -1 | sed 's/.*:\([0-9]*\)$/\1/'
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
        local new_ip=$(echo "$resolved_ips" | grep ':' | head -1)
        [ -z "$new_ip" ] && new_ip=$(echo "$resolved_ips" | head -1)
        
        local port=$(get_endpoint_port "$conf")
        local peer=$(get_wg_peer_pubkey "$iface")
        local new_endpoint="$new_ip:$port"
        
        # Wrap IPv6 in brackets
        if echo "$new_ip" | grep -q ':'; then
            new_endpoint="[$new_ip]:$port"
        fi
        
        echo "$(date): $iface endpoint $endpoint_host IP mismatch. WG: $wg_ip, DNS: $resolved_ips. Updating to $new_endpoint"
        wg set "$iface" peer "$peer" endpoint "$new_endpoint"
    fi
}

while true; do
    for conf in /config/wg_confs/*.conf; do
        [ -f "$conf" ] || continue
        check_and_restart "$conf"
    done
    sleep "${CHECK_INTERVAL:-60}"
done
