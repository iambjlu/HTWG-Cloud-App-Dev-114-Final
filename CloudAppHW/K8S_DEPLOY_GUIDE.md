# 部署指南 / Deployment Guide

本指南將協助您在 OrbStack (Kubernetes) 環境中部署此全端應用程式。
This guide will help you deploy this full-stack application in an OrbStack (Kubernetes) environment.

---

## 繁體中文 (Traditional Chinese)

### 1. 先決條件 (Prerequisites)

在開始之前，請確保您已安裝並設定以下工具：

*   **OrbStack**: 用於 macOS 的 Docker 和 Kubernetes 輕量級環境。
    *   請確保已在 OrbStack 設定中啟用 **Kubernetes**。
*   **Docker CLI**: 用於建置映像檔。
*   **kubectl**: 用於管理 Kubernetes 叢集 (通常隨 OrbStack 行安裝)。

驗證安裝：
```bash
docker --version
kubectl version --client
```

### 2. 建置 Docker 映像檔 (Build Images)

我們需要分別為後端 (Backend) 和前端 (Frontend) 建置 Docker 映像檔。請在專案根目錄 (`CloudAppHW/CloudAppHW`) 執行：

```bash
# 建置後端映像檔
docker build -t backend-api:latest ./backend-api

# 建置 Ad Service 映像檔
docker build -t ad-service:latest ./ad-service

# 建置前端映像檔
docker build -t frontend-vue:latest ./frontend-vue
```

### 3. 設定機密資訊 (Configure Secrets)

**重要：** 本專案需要敏感的 API 金鑰才能運作。請勿直接提交真實的機密檔案到版本控制系統。

1.  **複製範例檔案**
    在 `k8s/` 目錄中，我們提供了一個範例檔。請將其複製為 `backend-secrets.yaml`：
    ```bash
    cp k8s/backend-secrets.example.yaml k8s/backend-secrets.yaml
    ```

2.  **填寫機密資訊**
    使用文字編輯器打開 `k8s/backend-secrets.yaml`，並填入以下資訊：
    *   `GEMINI_API_KEY`: 您的 Google Gemini API Key。
    *   `GCP_SERVICE_ACCOUNT_JSON`: 您的 Google Cloud Service Account JSON 內容 (請保留完整 JSON 結構)。

### 4. 部署至 Kubernetes (Deploy)

使用 `kubectl` 應用 `k8s/` 目錄下的所有設定檔（包含資料庫、後端、前端與 Secrets）：

```bash
kubectl apply -f k8s/
```

### 5. 檢查部署狀態 (Check Status)

部署需要一點時間（尤其是 MySQL 初始化）。您可以使用以下指令查看 Pod 狀態：

```bash
kubectl get pods
```

請等待直到所有 Pod 的狀態皆為 `Running`。

### 6. 存取應用程式 (Access Application)

前端服務設為 LoadBalancer 類型，您可以透過 Browser 直接訪問。

**查看服務位址：**
```bash
kubectl get service frontend-service
```
通常在 OrbStack 中，您可以直接訪問：
*   **http://localhost**
*   或 `EXTERNAL-IP` 顯示的位址。

### 常見操作與故障排除

**重置資料庫 (Reset Database)**
如果您需要清空並重新建立資料庫，可以執行以下指令：

```bash
# 刪除並重新部署 MySQL 服務
kubectl delete -f k8s/mysql.yaml
kubectl apply -f k8s/mysql.yaml
```
*注意：這將會清除資料庫中的所有資料。*

**重新部署應用程式 (Redeploy App)**
當您修改了程式碼並重新建置了 Docker 映像檔後，需要重啟 Pod 來套用變更：

```bash
# 重啟後端
kubectl rollout restart deployment backend

# 重啟 Ad Service
kubectl rollout restart deployment ad-service

# 重啟前端
kubectl rollout restart deployment frontend
```

**刪除所有部署 (Delete All Deployments)**
如果您想要移除所有已部署的資源 (包含服務、Pod、ConfigMap 等)：

```bash
kubectl delete -f k8s/
```

## Google Kubernetes Engine (GKE) 部署指南

如果您希望將應用程式部署到 Google Cloud 的 GKE，我們已為您準備了專用的 `k8s-gke/` 設定檔。

**1. 準備工作 (GKE Prerequisites)**
*   建立 Google Cloud 專案與標準 GKE 叢集 (Standard Cluster)。
*   安 `gcloud` SDK 並登入：`gcloud auth login`。
*   **<CLUSTER_NAME> 是什麼？**: 這是您在 Google Cloud Console 建立叢集時所取的名稱 (例如 `my-cluster`)。
*   設定 `kubectl` 連接 GKE：
    ```bash
    # 把 <CLUSTER_NAME> 換成您的叢集名稱，<REGION> 換成區域 (如 us-central1)
    gcloud container clusters get-credentials <CLUSTER_NAME> --region <REGION>
    ```

**2. 推送映像檔 (Push Images)**
GKE 無法讀取您本地的 Docker 映像檔，必須將其推送到 Google Container Registry (GCR)。

```bash
# 設定專案 ID (確保您已選擇正確的專案)
export PROJECT_ID=$(gcloud config get-value project)

# 標記映像檔 (Tag)
docker tag backend-api:latest gcr.io/$PROJECT_ID/backend-api:latest
docker tag ad-service:latest gcr.io/$PROJECT_ID/ad-service:latest
docker tag frontend-vue:latest gcr.io/$PROJECT_ID/frontend-vue:latest

# 推送映像檔 (Push)
docker push gcr.io/$PROJECT_ID/backend-api:latest
docker push gcr.io/$PROJECT_ID/ad-service:latest
docker push gcr.io/$PROJECT_ID/frontend-vue:latest
```

**3. 更新設定檔 (Update Configs)**
我們已經複製了一份專用的設定檔在 `k8s-gke/` 目錄中，您只需要將其中的 `YOUR_PROJECT_ID` 替換為您的實際 Project ID。

您可以使用以下指令快速替換 (或者手動編輯 `k8s-gke/backend.yaml` 和 `k8s-gke/frontend.yaml`)：

```bash
# 使用 sed 快速替換所有 YOUR_PROJECT_ID
# (macOS 需要 '' 空字串參數)
sed -i '' "s/YOUR_PROJECT_ID/$PROJECT_ID/g" k8s-gke/backend.yaml
sed -i '' "s/YOUR_PROJECT_ID/$PROJECT_ID/g" k8s-gke/ad-service.yaml
sed -i '' "s/YOUR_PROJECT_ID/$PROJECT_ID/g" k8s-gke/frontend.yaml
```

**4. 部署到 GKE (Deploy)**
使用 `k8s-gke/` 目錄進行部署：

```bash
kubectl apply -f k8s-gke/
```

**5. 取得外部 IP**
GKE 需要幾分鐘來分配外部 IP：
```bash
kubectl get service frontend-service --watch
```
等待 `EXTERNAL-IP` 出現後，即可透過瀏覽器訪問。

---

## English

### 1. Prerequisites

Before starting, ensure you have the following installed and configured:

*   **OrbStack**: Lightweight Docker and Kubernetes environment for macOS.
    *   Ensure **Kubernetes** is enabled in OrbStack settings.
*   **Docker CLI**: For building images.
*   **kubectl**: For managing the Kubernetes cluster.

Verify installation:
```bash
docker --version
kubectl version --client
```

### 2. Build Docker Images

Build the Docker images for both the backend and frontend. Run these commands from the project root (`CloudAppHW/CloudAppHW`):

```bash
# Build Backend Image
docker build -t backend-api:latest ./backend-api

# Build Ad Service Image
docker build -t ad-service:latest ./ad-service

# Build Frontend Image
docker build -t frontend-vue:latest ./frontend-vue
```

### 3. Configure Secrets
**Important:** This project requires sensitive API keys to function. Do not commit actual secret files to version control.

1.  **Copy Example File**
    We have provided an example file in the `k8s/` directory. Copy it to `backend-secrets.yaml`:
    ```bash
    cp k8s/backend-secrets.example.yaml k8s/backend-secrets.yaml
    ```

2.  **Fill in Secrets**
    Open `k8s/backend-secrets.yaml` with a text editor and fill in the following:
    *   `GEMINI_API_KEY`: Your Google Gemini API Key.
    *   `GCP_SERVICE_ACCOUNT_JSON`: Your Google Cloud Service Account JSON content (keep the full JSON structure).

### 4. Deploy to Kubernetes

Apply all configuration files located in the `k8s/` directory (includes Database, Backend, Frontend, and Secrets):

```bash
kubectl apply -f k8s/
```

### 5. Check Status

Deployment might take a moment, especially for MySQL initialization. Check the status of your Pods:

```bash
kubectl get pods
```

Wait until all Pods show a status of `Running`.

### 6. Access the Application

The frontend service is configured as a LoadBalancer. You can access it via your browser.

**Get Service URL:**
```bash
kubectl get service frontend-service
```
Typically in OrbStack, you can access the app at:
*   **http://localhost**
*   Or the address shown in `EXTERNAL-IP`.

### Common Operations & Troubleshooting

**Reset Database**
If you need to wipe and recreate the database:

```bash
# Delete and re-apply the MySQL configuration
kubectl delete -f k8s/mysql.yaml
kubectl apply -f k8s/mysql.yaml
```
*Note: This will delete all data in the database.*

**Redeploy Application**
After modifying code and rebuilding Docker images, restart the Pods to apply changes:

```bash
# Restart Backend
kubectl rollout restart deployment backend

# Restart Ad Service
kubectl rollout restart deployment ad-service

# Restart Frontend
kubectl rollout restart deployment frontend
```

**Delete All Deployments**
If you want to remove all deployed resources (services, pods, configmaps, etc.):

```bash
kubectl delete -f k8s/
```

## Google Kubernetes Engine (GKE) Deployment Guide

If you wish to deploy to Google Cloud's GKE, we have prepared a dedicated `k8s-gke/` configuration folder for you.

**1. GKE Prerequisites**
*   Create a Google Cloud Project and a Standard GKE Cluster.
*   Install `gcloud` SDK and login: `gcloud auth login`.
*   **What is <CLUSTER_NAME>?**: This is the name you assigned to your cluster when creating it in the Google Cloud Console (e.g., `my-cluster`).
*   Configure `kubectl` to connect to your GKE cluster:
    ```bash
    # Replace <CLUSTER_NAME> with your cluster name, and <REGION> with the region (e.g., us-central1)
    gcloud container clusters get-credentials <CLUSTER_NAME> --region <REGION>
    ```

**2. Push Images**
GKE cannot access your local OrbStack/Docker images. You must push them to Google Container Registry (GCR).

```bash
# Set Project ID (Ensure you have selected the correct project)
export PROJECT_ID=$(gcloud config get-value project)

# Tag Images
docker tag backend-api:latest gcr.io/$PROJECT_ID/backend-api:latest
docker tag ad-service:latest gcr.io/$PROJECT_ID/ad-service:latest
docker tag frontend-vue:latest gcr.io/$PROJECT_ID/frontend-vue:latest

# Push Images
docker push gcr.io/$PROJECT_ID/backend-api:latest
docker push gcr.io/$PROJECT_ID/ad-service:latest
docker push gcr.io/$PROJECT_ID/frontend-vue:latest
```

**3. Update Configurations**
We have copied a dedicated set of configuration files to the `k8s-gke/` directory. You only need to replace `YOUR_PROJECT_ID` with your actual Project ID.

You can use the following command to quickly replace it (or manually edit `k8s-gke/backend.yaml` and `k8s-gke/frontend.yaml`):

```bash
# Use sed to quickly replace all YOUR_PROJECT_ID
# (macOS requires '' empty string argument)
sed -i '' "s/YOUR_PROJECT_ID/$PROJECT_ID/g" k8s-gke/backend.yaml
sed -i '' "s/YOUR_PROJECT_ID/$PROJECT_ID/g" k8s-gke/ad-service.yaml
sed -i '' "s/YOUR_PROJECT_ID/$PROJECT_ID/g" k8s-gke/frontend.yaml
```

**4. Deploy to GKE**
Deploy using the `k8s-gke/` directory:

```bash
kubectl apply -f k8s-gke/
```

**5. Get External IP**
GKE takes a few minutes to assign an external IP:
```bash
kubectl get service frontend-service --watch
```
Wait for the `EXTERNAL-IP` to appear, then access it via your browser.
