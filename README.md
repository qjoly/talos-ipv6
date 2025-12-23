# talos-ipv6

Talos Linux cluster running in IPv6-only mode with Cilium CNI. Be careful, my setup is probably not optimal or secure for production use.

## Prerequisites

- `talhelper`
- `talosctl`
- `kubectl`
- `cilium` CLI

## Configuration

Edit [talconfig.yaml](talconfig.yaml) with your cluster settings:
- Node hostnames and IPv6 addresses
- Pod and service subnets
- Network interface configuration

## Deployment

Generate and apply configuration:
```bash
make all
```

Individual steps:
```bash
make genconfig        # Generate Talos configs
make replace-ipv4     # Replace IPv4 with IPv6 in talosconfig
make apply            # Apply config to nodes
make bootstrap        # Bootstrap the cluster
make kubeconfig       # Get kubeconfig
make install-cilium   # Install Cilium CNI
```

## Reset

```bash
make reset
```
