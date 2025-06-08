# node-exporter-with-consul
## Update `prometheus.yml`
```
  - job_name: node
    metrics_path: /metrics
    consul_sd_configs:
      - server: '<Consul-IP-Address:Port>'
        services: ['node-exporter']
    relabel_configs:
      - source_labels: [__meta_consul_service_id]
        target_label: instance
        action: replace

      - source_labels: [__meta_consul_service_id]
        target_label: node
        action: replace

      - source_labels: [__meta_consul_tags]
        target_label: tags
        action: replace
```

## Change hostname first
```
read -p "Enter new hostname: " NEW_HOSTNAME && sudo hostnamectl set-hostname "$NEW_HOSTNAME" && echo "Hostname changed to $NEW_HOSTNAME" && echo "Current hostname is: $(hostname)"
```
## Install node exporter and register with consul
```
wget -O install-node-exporter-with-consul.sh https://raw.githubusercontent.com/ngocdoan/node-exporter-with-consul/refs/heads/main/install-node-exporter-with-consul.sh && chmod +x install-node-exporter-with-consul.sh && ./install-node-exporter-with-consul.sh
```
## Deregister with consul
```
wget -O deregister-with-consul.sh https://raw.githubusercontent.com/ngocdoan/node-exporter-with-consul/refs/heads/main/deregister-with-consul.sh && chmod +x deregister-with-consul.sh && ./deregister-with-consul.sh
```
