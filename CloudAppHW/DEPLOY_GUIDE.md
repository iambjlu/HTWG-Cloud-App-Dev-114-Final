# 部署指南 / Deployment Guide

這份文件說明如何將此專案部署到 OrbStack 的 Kubernetes 環境。
This document explains how to deploy this project to OrbStack's Kubernetes environment.

---

## 繁體中文

### 安裝說明

1.  **準備工作**
    確保您已安裝 OrbStack 並啟用 Kubernetes。
    確保 `kubectl` 和 `docker` 指令可用。

2.  **建置 Docker 映像檔**
    我們需要為後端和前端建置 Docker 映像檔。請在專案根目錄執行以下指令：

    ```bash
    # 建置後端映像檔
    docker build -t backend-api:latest ./backend-api

    # 建置前端映像檔
    docker build -t frontend-vue:latest ./frontend-vue
    ```

3.  **部署到 Kubernetes**
    使用 `kubectl` 應用我們準備好的設定檔：

    ```bash
    # 應用所有設定 (資料庫、後端、前端)
    kubectl apply -f k8s/
    ```

4.  **驗證部署**
    查看 Pod 狀態，確保所有服務都顯示 `Running`：

    ```bash
    kubectl get pods
    ```

### 使用說明

1.  **存取網站**
    前端服務已設定為 `LoadBalancer` 類型。OrbStack 會自動分配一個網址或 localhost 端口。
    執行以下指令查看外部 IP (External-IP)：

    ```bash
    kubectl get service frontend-service
    ```

    通常在 OrbStack 中，您可以直接瀏覽 `http://localhost` 或顯示的 IP 位址。

2.  **功能測試**
    -   打開瀏覽器訪問前端頁面。
    -   註冊/登入並嘗試建立行程。
    -   系統會透過 Nginx 將 `/api`請求轉發給後端，後端會連接 MySQL 資料庫。

---

## English

### Installation Guide

1.  **Prerequisites**
    Ensure OrbStack is installed and Kubernetes is enabled.
    Ensure `kubectl` and `docker` commands are available.

2.  **Build Docker Images**
    We need to build Docker images for both the backend and frontend. Run the following commands in the project root:

    ```bash
    # Build backend image
    docker build -t backend-api:latest ./backend-api

    # Build frontend image
    docker build -t frontend-vue:latest ./frontend-vue
    ```

3.  **Deploy to Kubernetes**
    Apply the prepared configuration files using `kubectl`:

    ```bash
    # Apply all configurations (Database, Backend, Frontend)
    kubectl apply -f k8s/
    ```

4.  **Verify Deployment**
    Check the status of the pods to ensure everything is `Running`:

    ```bash
    kubectl get pods
    ```

### Usage Guide

1.  **Access the Application**
    The frontend service is configured as `LoadBalancer`. OrbStack will automatically assign a URL or localhost port.
    Run the following command to see the External-IP:

    ```bash
    kubectl get service frontend-service
    ```

    Typically in OrbStack, you can access it directly at `http://localhost` or the displayed IP address.

2.  **Functional Testing**
    -   Open your browser and visit the frontend page.
    -   Register/Login and try to create an itinerary.
    -   The system will proxy `/api` requests to the backend via Nginx, and the backend will connect to the MySQL database.
