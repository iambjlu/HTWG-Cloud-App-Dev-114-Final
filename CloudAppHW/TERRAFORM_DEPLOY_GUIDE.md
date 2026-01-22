# 🚀 Terraform GKE 部署指南 / GKE Deployment Guide with Terraform

本指南將協助您使用 **Terraform (IaC)** 自動化部署應用程式到 **Google Kubernetes Engine (GKE)**。

---

## 目錄 / Table of Contents

1. [前置準備 (Cloud Console)](#前置準備-cloud-console)
2. [本機環境設定](#本機環境設定)
3. [Terraform 設定](#terraform-設定)
4. [部署執行](#部署執行)
5. [應用程式部署](#應用程式部署)
6. [清理資源](#清理資源)
7. [常見問題](#常見問題)

---

## 前置準備 (Cloud Console)

### Step 1: 建立 GCP 專案

1. 前往 [Google Cloud Console](https://console.cloud.google.com/)
2. 點擊頂部的專案選擇器
3. 點擊 **「新增專案」**
4. 輸入專案名稱 (例如: `cloud-app-hw`)
5. 記下專案 ID (這個 ID 是唯一的，無法更改)

```
📝 記錄你的 Project ID: ____________________
```

### Step 2: 啟用計費帳戶

1. 前往 [Billing](https://console.cloud.google.com/billing)
2. 確保有一個有效的計費帳戶
3. 將計費帳戶連結到你的專案

> ⚠️ **注意**: 如果你是學生，可以申請 [Google Cloud for Students](https://cloud.google.com/edu) 獲得免費額度

### Step 3: 啟用必要的 API

在 Cloud Console 中，前往 [API 程式庫](https://console.cloud.google.com/apis/library) 並啟用：

| API 名稱 | 說明 | 直接連結 |
|----------|------|----------|
| Kubernetes Engine API | 用於建立 GKE 叢集 | [啟用](https://console.cloud.google.com/apis/library/container.googleapis.com) |
| Container Registry API | 用於儲存 Docker 映像 | [啟用](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com) |
| Compute Engine API | 用於建立虛擬機 | [啟用](https://console.cloud.google.com/apis/library/compute.googleapis.com) |

或者使用 gcloud 指令一次啟用：

```bash
gcloud services enable container.googleapis.com containerregistry.googleapis.com compute.googleapis.com --project=YOUR_PROJECT_ID
```

### Step 4: 建立 Service Account 並下載金鑰

1. 前往 [IAM & Admin → Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts)
2. 點擊 **「建立服務帳戶」**
3. 填寫：
   - 名稱: `terraform-deployer`
   - ID: `terraform-deployer`
4. 點擊 **「建立並繼續」**
5. 授予以下角色 (點擊「新增其他角色」)：
   - `Kubernetes Engine Admin`
   - `Compute Admin`
   - `Storage Admin`
   - `Service Account User`
6. 點擊 **「完成」**
7. 在服務帳戶列表中，點擊剛建立的帳戶
8. 前往 **「金鑰」** 標籤
9. 點擊 **「新增金鑰」** → **「建立新金鑰」** → 選擇 **JSON**
10. 金鑰會自動下載，請妥善保管！

---

## 本機環境設定

### 安裝必要工具

#### 1. 安裝 Terraform

```bash
# macOS (使用 Homebrew)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# 驗證安裝
terraform --version
```

#### 2. 安裝 Google Cloud SDK

```bash
# macOS (使用 Homebrew)
brew install --cask google-cloud-sdk

# 驗證安裝
gcloud --version
```

#### 3. 登入 Google Cloud

```bash
# 登入你的 Google 帳戶
gcloud auth login

# 設定預設專案
gcloud config set project YOUR_PROJECT_ID

# 設定 Docker 認證 (推送映像用)
gcloud auth configure-docker
```

---

## Terraform 設定

### Step 1: 準備設定檔

```bash
# 進入 terraform 目錄
cd CloudAppHW/terraform

# 複製範例設定檔
cp terraform.tfvars.example terraform.tfvars

# 複製 Service Account 金鑰到此目錄
cp ~/Downloads/your-downloaded-key.json credentials.json
```

### Step 2: 編輯 terraform.tfvars

打開 `terraform.tfvars` 並填入你的設定：

```hcl
# 必填項目
project_id       = "your-actual-project-id"  # 從 Cloud Console 獲取
credentials_file = "credentials.json"         # Service Account 金鑰

# 區域設定 (根據需求調整)
region = "europe-west1"  # 歐洲區域

# Cluster 設定
cluster_name = "cloud-app-cluster"
environment  = "dev"

# 節點設定 (調整以控制成本)
machine_type    = "e2-medium"  # 2 vCPU, 4GB RAM
node_count      = 2            # 初始節點數
max_node_count  = 4            # 最大節點數
use_preemptible = true         # 使用可搶佔節點省錢
```

---

## 部署執行

### Step 1: 初始化 Terraform

```bash
cd CloudAppHW/terraform

# 初始化 Terraform (下載 provider)
terraform init
```

你會看到類似輸出：
```
Initializing the backend...
Initializing provider plugins...
- Installing hashicorp/google v5.x.x...
- Installing hashicorp/kubernetes v2.x.x...

Terraform has been successfully initialized!
```

### Step 2: 預覽變更 (Plan)

```bash
# 查看 Terraform 將要執行的操作
terraform plan
```

這會顯示：
- 將建立哪些資源
- 預估的成本影響
- 任何潛在問題

### Step 3: 執行部署 (Apply)

```bash
# 應用變更 (建立 GKE Cluster)
terraform apply
```

輸入 `yes` 確認後，Terraform 會開始建立資源。

> ⏱️ **預計時間**: 約 10-15 分鐘

成功後你會看到輸出：
```
Apply complete! Resources: X added, 0 changed, 0 destroyed.

Outputs:

cluster_name = "cloud-app-cluster"
kubectl_command = "gcloud container clusters get-credentials cloud-app-cluster --region europe-west1 --project your-project-id"
...
```

---

## 應用程式部署

GKE Cluster 建立完成後，按以下步驟部署應用程式：

### Step 1: 連接到 Cluster

```bash
# 執行 Terraform 輸出的指令
gcloud container clusters get-credentials cloud-app-cluster --region europe-west1 --project YOUR_PROJECT_ID

# 驗證連接
kubectl get nodes
```

### Step 2: 建置並推送 Docker 映像

```bash
# 回到專案根目錄
cd ../

# 設定 Project ID
export PROJECT_ID=$(gcloud config get-value project)

# 建置映像
docker build -t gcr.io/$PROJECT_ID/backend-api:latest ./backend-api
docker build -t gcr.io/$PROJECT_ID/ad-service:latest ./ad-service
docker build -t gcr.io/$PROJECT_ID/frontend-vue:latest ./frontend-vue

# 推送到 GCR
docker push gcr.io/$PROJECT_ID/backend-api:latest
docker push gcr.io/$PROJECT_ID/ad-service:latest
docker push gcr.io/$PROJECT_ID/frontend-vue:latest
```

### Step 3: 更新 K8s 設定

```bash
# 更新 k8s-gke 設定檔中的 Project ID
sed -i '' "s/YOUR_PROJECT_ID/$PROJECT_ID/g" k8s-gke/*.yaml
```

### Step 4: 設定 Secrets

```bash
# 複製並編輯 Secrets 檔案
cp k8s-gke/backend-secrets.example.yaml k8s-gke/backend-secrets.yaml

# 編輯 backend-secrets.yaml 填入你的 API Keys
# - GEMINI_API_KEY
# - GCP_SERVICE_ACCOUNT_JSON
```

### Step 5: 部署應用程式

```bash
# 部署所有 K8s 資源
kubectl apply -f k8s-gke/

# 查看部署狀態
kubectl get pods --watch

# 等待所有 Pod 變成 Running
```

### Step 6: 取得外部 IP

```bash
# 查看 frontend service 的外部 IP
kubectl get service frontend-service --watch
```

等待 `EXTERNAL-IP` 出現後，即可透過瀏覽器訪問你的應用程式！

---

## 清理資源

當你不再需要這些資源時（**重要：避免產生費用**）：

```bash
# 刪除 K8s 資源
kubectl delete -f k8s-gke/

# 刪除 GKE Cluster 和所有 Terraform 管理的資源
cd terraform
terraform destroy
```

輸入 `yes` 確認刪除所有資源。

---

## 常見問題

### Q: terraform init 失敗？

**可能原因：** 網路問題或 provider 版本不相容

```bash
# 更新 provider
terraform init -upgrade
```

### Q: 401 Unauthorized 錯誤？

**可能原因：** Service Account 權限不足或金鑰過期

1. 確認 `credentials.json` 路徑正確
2. 確認 Service Account 有足夠權限
3. 確認金鑰沒有過期

### Q: 費用太高怎麼辦？

調整 `terraform.tfvars`：
```hcl
machine_type    = "e2-small"  # 使用更小的機器
node_count      = 1           # 減少節點數
use_preemptible = true        # 使用可搶佔節點
```

### Q: 如何查看目前費用？

前往 [Billing](https://console.cloud.google.com/billing) 查看目前的費用使用量。

---

## 成本估算參考

| 配置 | 月估計成本 (USD) |
|------|-----------------|
| e2-small × 1 (Preemptible) | ~$5-10 |
| e2-medium × 2 (Preemptible) | ~$20-30 |
| e2-standard-2 × 2 (Standard) | ~$100-150 |

> 💡 **提示**: 使用 [GCP Pricing Calculator](https://cloud.google.com/products/calculator) 獲得精確估算

---

## 快速參考指令

```bash
# Terraform 常用指令
terraform init      # 初始化
terraform plan      # 預覽變更
terraform apply     # 執行部署
terraform destroy   # 刪除所有資源
terraform output    # 查看輸出值

# kubectl 常用指令
kubectl get pods                    # 查看 Pod 狀態
kubectl get services                # 查看服務
kubectl logs <pod-name>             # 查看日誌
kubectl describe pod <pod-name>     # 詳細資訊
kubectl rollout restart deployment <name>  # 重啟部署
```

---

## 架構圖

```
┌─────────────────────────────────────────────────────────────────┐
│                     Google Cloud Platform                        │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    GKE Cluster                              │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │ │
│  │  │  Frontend   │  │  Backend    │  │  Ad-Service │         │ │
│  │  │   (Vue.js)  │  │   (Node)    │  │   (Node)    │         │ │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘         │ │
│  │         │                │                │                 │ │
│  │         └────────────────┼────────────────┘                 │ │
│  │                          │                                  │ │
│  │                   ┌──────┴──────┐                          │ │
│  │                   │    MySQL    │                          │ │
│  │                   └─────────────┘                          │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                              ▲                                   │
│  ┌───────────────────────────┴────────────────────────────────┐ │
│  │              Container Registry (GCR)                       │ │
│  │  backend-api:latest  ad-service:latest  frontend-vue:latest │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │
                    ┌─────────┴─────────┐
                    │     Terraform     │
                    │   (IaC 自動化)    │
                    └───────────────────┘
```

---

**🎉 恭喜！你現在可以使用 Terraform 自動化部署你的雲端應用程式了！**
