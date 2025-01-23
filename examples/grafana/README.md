# dependency
helm dependency update .

# Install
helm upgrade --install grafana . -f values.yaml -n grafana --create-namespace

# Uninstall
helm uninstall grafana -n grafana