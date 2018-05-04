# Configure cgroup driver used by kubelet on Master Node
# sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# systemctl daemon-reload
# systemctl restart kubelet

# Init kubeadmin
kubeadm init
mkdir -p $HOME/.kube
sudo cp -rif /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf

# Installing pod network
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml

# Isolate master note
kubectl taint nodes --all node-role.kubernetes.io/master-

# Create kube_terraform folder for storage kubeadmin join informations
mkdir -p /root/kube_terraform
(
  cd /root/kube_terraform
  kubeadm token create > token
  openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* /sha256:/' > discovery-token-ca-cert-hash
  kubeadm config view | fgrep "advertiseAddress" | sed -e 's/.*: *//' > api-address
  kubeadm config view | fgrep "bindPort" | sed -e 's/.*: *//' > api-port
)