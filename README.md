# WireGuard with Dynamic DNS Support

Docker image based on [linuxserver/wireguard](https://github.com/linuxserver/docker-wireguard) that automatically updates WireGuard peer endpoints when their DNS records change.

## Features

- Monitors DNS changes for WireGuard peer endpoints
- Automatically updates peer endpoints without restarting the interface
- Prefers IPv6 addresses when available
- Configurable DNS server and check interval
- Uses busybox-compatible shell scripts (no additional dependencies)

## Usage

```yaml
version: "3.8"

services:
  wireguard:
    image: ghcr.io/dphi/wireguard-dynamic-dns:1.0
    container_name: wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - DNS_SERVER=8.8.8.8
      - CHECK_INTERVAL=60
    volumes:
      - ./config:/config
      - /lib/modules:/lib/modules
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | `1000` | User ID for file permissions |
| `PGID` | `1000` | Group ID for file permissions |
| `TZ` | `Etc/UTC` | Timezone |
| `DNS_SERVER` | `8.8.8.8` | DNS server to use for endpoint resolution |
| `CHECK_INTERVAL` | `60` | Interval in seconds between DNS checks (minimum 60) |

## How It Works

The image includes a monitoring script that:

1. Scans all WireGuard configuration files in `/config/wg_confs/*.conf`
2. Extracts endpoint hostnames from the `Endpoint` parameter
3. Resolves the hostname using the configured DNS server
4. Compares resolved IPs with the current WireGuard peer endpoint
5. Updates the endpoint using `wg set` if none of the resolved IPs match
6. Prefers IPv6 addresses when multiple IPs are returned

The script runs continuously and checks for changes at the configured interval.

## Upstream Documentation

For additional configuration options and detailed documentation, see the [linuxserver/wireguard documentation](https://github.com/linuxserver/docker-wireguard).

## License

This project extends the linuxserver/wireguard image. See upstream repository for licensing information.
