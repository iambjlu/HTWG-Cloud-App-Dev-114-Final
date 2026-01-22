# put link to CloudAppHW.zip in [zip] secret

#configure.sh VNC_USER_PASSWORD VNC_PASSWORD TS_KEY
echo "--- VM Info ---"
echo "== 系統資訊 System Info =================="
uname -a

echo "== CPU 資訊 CPU Info ===================="
lscpu

echo "== 記憶體資訊 RAM Info ==================="
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable"
free -h

echo "== 磁碟資訊 Disk Info ==================="
lsblk
df -h

echo "== GPU / 顯示卡 GPU/Display============="
lspci | grep -i vga

echo "== 作業系統版本 OS Info ================"
cat /etc/os-release

echo "== 開機時間與系統運行時間 OS Boot time =="
uptime

echo "== 網路介面 Network Interface ========"
ip a | grep -E "^[0-9]+:|inet "

echo "== 主機名稱 Host name ================"
hostname

echo "== 處理器資訊（詳細）CPU Info =========="
cat /proc/cpuinfo | grep -E "model name|cpu MHz|cache size" | uniq
echo "---------------"


sudo hostnamectl set-hostname "ubuntu-$(hostname)"
# Free up disk space on GitHub Actions Runner
echo "🧹 Cleaning up disk space..."
sudo rm -rf /usr/share/dotnet
sudo rm -rf /usr/local/lib/android
sudo rm -rf /opt/ghc
sudo rm -rf /opt/hostedtoolcache/CodeQL
sudo docker system prune -a -f
df -h

sudo apt update
sudo apt install unzip






sudo mkdir -p /opt/cni/bin
cd /tmp
CNI_VERSION="v1.4.0"
ARCH="amd64"
curl -L -o cni-plugins.tgz \
  https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz
sudo tar -C /opt/cni/bin -xzvf cni-plugins.tgz
ls /opt/cni/bin
cd ~
sudo apt update
sudo apt-get remove -y docker-ce docker-ce-cli containerd.io || true
sudo apt-get install -y docker.io
sudo apt-get install -y unzip
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
sudo apt install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
  | sudo gpg --dearmor --yes --batch -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
  https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list
# Load kernel modules for containerd & Kubernetes
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
echo "Modules loaded: $(lsmod | grep br_netfilter)"

# Sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
# Clean previous CNI configurations to prevent conflicts
sudo rm -rf /etc/cni/net.d/*

kubectl version --client
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Download Flannel manifest first to ensure network stability
curl -LO https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl apply -f kube-flannel.yml

kubectl get nodes
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

echo "⏳ 等待 Flannel 資源建立 Waiting for Flannel resources..."
# Wait up to 60 seconds for the DaemonSet to be created
for i in {1..30}; do
  if kubectl get daemonset/kube-flannel-ds -n kube-flannel > /dev/null 2>&1; then
    echo "Found Flannel DaemonSet."
    break
  fi
  echo "Waiting for DaemonSet creation... ($i)"
  sleep 2
done

echo "⏳ 等待 Flannel 網路元件啟動 Waiting for Flannel..."
kubectl rollout status daemonset/kube-flannel-ds -n kube-flannel --timeout=300s

echo "⏳ 等待 Flannel 網路設定檔 Waiting for Flannel subnet.env..."
subnet_found=false
# Wait up to 60 seconds for the subnet.env file to be created
for i in {1..30}; do
  if [ -f /run/flannel/subnet.env ]; then
    echo "Found Flannel subnet.env."
    cat /run/flannel/subnet.env
    subnet_found=true
    break
  fi
  echo "Waiting for subnet.env creation... ($i)"
  sleep 2
done

if [ "$subnet_found" = false ]; then
  echo "❌ Error: Flannel subnet.env file not found after waiting."
  echo "--- Flannel Pod Status ---"
  kubectl get pods -n kube-flannel
  echo "--- Flannel Pod Logs ---"
  kubectl logs -l app=flannel -n kube-flannel --tail=50
  echo "--- Node Status ---"
  kubectl describe node
  exit 1
fi

# Restart containerd to ensure CNI plugins pick up the new network config
sudo systemctl restart containerd



wget $zip
unzip CloudAppHW.zip

cd CloudAppHW/CloudAppHW
kubectl wait node $(hostname) --for=condition=Ready --timeout=300s
sudo mkdir -p /mnt/mysql-data
cat << 'EOF' > mysql-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/mysql-data
    type: DirectoryOrCreate
EOF
kubectl apply -f mysql-pv.yaml
kubectl get pv
docker --version
kubectl version --client
echo "🐳 Building Docker images..."
docker build -t backend-api:latest ./backend-api
docker build -t frontend-vue:latest ./frontend-vue

echo "🔄 Importing images to containerd (k8s.io namespace)..."
# Save and import backend image
docker save backend-api:latest -o backend.tar
sudo ctr -n=k8s.io images import backend.tar
rm backend.tar
docker rmi backend-api:latest # Free up space in Docker Daemon

# Save and import frontend image
docker save frontend-vue:latest -o frontend.tar
sudo ctr -n=k8s.io images import frontend.tar
rm frontend.tar
docker rmi frontend-vue:latest # Free up space in Docker Daemon

# Prune all docker data to maximize space for K8s
docker system prune -a -f

# Check disk space
df -h
kubectl apply -f k8s/
echo "⏳ 等待應用程式啟動中 Waiting for pods to be ready..."

echo "安裝Tailscale..."
bash -c 'curl -fsSL https://tailscale.com/install.sh | sh'
echo "🚀 啟動 Tailscale service..."
sudo systemctl enable --now tailscaled
echo "⏳ 等待 Tailscale 服務啟動中..."
sudo tailscale up --authkey "$TS_KEY" --ssh
echo "---------"
echo "✅ 建立完成"
echo "使用者名稱Username: runner"
echo "Tailscale IP: $(tailscale ip -4)"
echo "SSH 連線指令: ssh runner@$(tailscale ip -4)"
echo "Webpage: http://$(tailscale ip -4):30501"
echo "---------"

# Wait loop to show pod status in real-time
end=$((SECONDS+300))
while [ $SECONDS -lt $end ]; do
    echo "=== 🕒 Time elapsed: $((300 - (end - SECONDS)))s ==="
    
    echo "--- 🚀 Deployments Status ---"
    kubectl get deploy
    
    echo "--- 📦 Pods Detail ---"
    kubectl get pods -o wide
    
    echo "--- 📢 Recent Events (Last 10) ---"
    kubectl get events --sort-by='.lastTimestamp' | tail -n 10
    
    echo "============================================="
    
    if kubectl wait --for=condition=available --timeout=1s deployment/backend deployment/frontend deployment/mysql >/dev/null 2>&1; then
        echo "✅ All deployments are ready!"
        break
    fi
    
    echo "Waiting for pods to be ready... (re-checking in 10s)"
    sleep 10
done

# Final check just in case the loop timed out or exited early
kubectl get pods




echo "💻 安裝 code-server..."
bash -c '
curl -fsSL https://code-server.dev/install.sh | sh
mkdir -p "$HOME/.certs"
cd "$HOME/.certs"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout code-server.key \
  -out code-server.crt \
  -subj "/C=TW/ST=Taiwan/L=Taipei/O=Dev/OU=Dev/CN=code-server"'
echo "⚙️ 寫入 code-server 設定..."
mkdir -p "$HOME/.config/code-server"
cat > "$HOME/.config/code-server/config.yaml" <<EOF
bind-addr: 0.0.0.0:8181
cert: $HOME/.certs/code-server.crt
cert-key: $HOME/.certs/code-server.key
auth: password
password: $1
EOF
rm -rf "$HOME/.cache"
echo "🚀 啟動 code-server..."

nohup code-server >/dev/null 2>&1 &


echo "---------"
echo "✅ 建立完成"
echo "使用者名稱Username: runner"
echo "Tailscale IP: $(tailscale ip -4)"
echo "SSH 連線指令: ssh runner@$(tailscale ip -4)"
echo "code-server: https://$(tailscale ip -4):8181/?folder=/home/runner"
echo "---------"
echo "現在時間 Now time: $(date '+%H:%M:%S') UTC"
echo "各項服務啟動中，建議2分鐘後( $(date -d '+120 seconds' '+%H:%M:%S') UTC )再嘗試連線"
echo "Suggestion: connect after 2 minutes ( $(date -d '+120 seconds' '+%H:%M:%S') UTC ) due to services still starting"
echo "---------"
echo "Webpage:"
sudo tailscale funnel 30501
wait