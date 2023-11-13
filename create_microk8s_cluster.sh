#!/usr/bin/env bash

RED="\e[31m"
LIGHTTURQUOISE="\e[96m"
GREEN='\033[1;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

set -euo pipefail

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Install snapd
echo -e "${YELLOW}Install snapd${NC}"
apt update -y
apt install snapd -y
echo -e "${LIGHTTURQUOISE}Install snapd - OK${NC}"

# Install microk8s
echo -e "${YELLOW}Install microk8s${NC}"
snap install microk8s --classic
echo -e "${LIGHTTURQUOISE}Install microk8s - OK${NC}"

# Install kubectl
echo -e "${YELLOW}Install kubectl${NC}"
snap install kubectl --classic
echo -e "${LIGHTTURQUOISE}Install kubectl - OK${NC}"

# Add current user to microk8s group
echo -e "${YELLOW}Add current user to microk8s group${NC}"
usermod -a -G microk8s netology
#chown -f -R netology ~/.kube
echo -e "${LIGHTTURQUOISE}Add current user to microk8s group - OK${NC}"

# Enable required microk8s addons
echo -e "${YELLOW}Enable required microk8s addons${NC}"
sleep 10
microk8s enable dns dashboard ingress storage rbac
echo -e "${LIGHTTURQUOISE}Enable required microk8s addons - OK${NC}"

#add public ip into cluster's config
echo -e "${YELLOW}add public ip into cluster's config${NC}"
ip_address=$(curl -s 2ip.ru)
sed -i "/^IP\.2/a IP.3 = $ip_address" /var/snap/microk8s/current/certs/csr.conf.template
echo -e "${LIGHTTURQUOISE}add public ip into cluster's config - OK${NC}"

# Refresh-certs
echo -e "${YELLOW}Refresh-certs${NC}"
microk8s refresh-certs --cert front-proxy-client.crt
echo -e "${LIGHTTURQUOISE}Refresh-certs - OK${NC}"

# Wait ready
echo -e "${YELLOW}Wait cluster ready${NC}"
microk8s status --wait-ready
microk8s kubectl wait -n kube-system --for=condition=ready pod --all --timeout=1h
echo -e "${YELLOW}Wait pending pods${NC}"
sleep 60s

while :
do
    if [[ -z $(microk8s kubectl get pods --all-namespaces | grep "0/1") ]]
    then
        echo "Pods ready"
        break
    else
        echo "Wait pending pods"
        sleep 5s
    fi
done
echo -e "${LIGHTTURQUOISE}Wait cluster ready - OK${NC}"

# View token

microk8s kubectl describe secret -n kube-system microk8s-dashboard-token | grep "token:"

echo " "
echo -e "${YELLOW}You can access the Kubernetes dashboard at https://$ip_address:10443 ${NC}"
echo " "
echo -e "${YELLOW}Useful commands:${NC}"
echo " "
echo -e "${YELLOW}newgrp microk8s${NC}"
echo " "

# Enable proxy
echo -e "${YELLOW}Enable Enable proxy ${NC}"
#microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443
microk8s dashboard-proxy