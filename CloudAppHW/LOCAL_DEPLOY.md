# 本地部署指南 / Local Deployment Guide (Bare Metal)

本指南說明如何在不使用 Docker 的情況下，直接於本機 (Local Machine) 部署此全端應用程式。
This guide explains how to deploy the full-stack application directly on your local machine (Bare Metal) without Docker.

---

## 前置需求 (Prerequisites)

在開始之前，請確保您的系統已安裝以下軟體：
Before you begin, ensure you have the following installed:

1.  **Node.js** (LTS version recommended)
    *   [Download Node.js](https://nodejs.org/)
    *   Verify: `node -v`, `npm -v`
2.  **MySQL Server**
    *   [Download MySQL](https://dev.mysql.com/downloads/mysql/)
    *   Ensure the MySQL service is running.
    *   Verify: `mysql --version`

---

## 快速開始 (Quick Start)

我們提供了自動化腳本來協助您設定環境、資料庫與啟動服務。
We provide automated scripts to help you set up the environment, database, and start services.

### 🍎 macOS / 🐧 Linux

1.  開啟終端機 (Terminal)。
2.  進入專案根目錄。
3.  執行腳本：
    ```bash
    chmod +x local_scripts/local_deploy.sh
    ./local_scripts/local_deploy.sh
    ```
4.  **設定 .env**：腳本執行過程中會暫停，並要求您編輯 `backend-api/.env` 和 `frontend-vue/.env`。
    *   **Backend**: 填入 MySQL 密碼、Gemini API Key 與 Google Cloud Service Account JSON。
    *   **Frontend**: 填入 Firebase Config 資訊。
5.  應用程式啟動後，前端通常位於 [http://localhost:5173](http://localhost:5173)。

1.  Open Terminal.
2.  Navigate to the project root.
3.  Run the script:
    ```bash
    chmod +x local_scripts/local_deploy.sh
    ./local_scripts/local_deploy.sh
    ```
4.  **Configure .env**: The script will pause and ask you to edit `backend-api/.env` and `frontend-vue/.env`.
    *   **Backend**: Fill in MySQL password, Gemini API Key, and GCP Service Account JSON.
    *   **Frontend**: Fill in Firebase Config details.
5.  Once started, the frontend is usually available at [http://localhost:5173](http://localhost:5173).

### 🪟 Windows (PowerShell)

1.  開啟 PowerShell (建議以系統管理員身分執行，避免權限問題)。
2.  進入專案根目錄。
3.  執行腳本：
    ```powershell
    .\local_scripts\local_deploy.ps1
    ```
    *   *如果遇到執行策略錯誤，請先執行 `Set-ExecutionPolicy RemoteSigned -Scope Process`。*
    *   *If you encounter execution policy errors, run `Set-ExecutionPolicy RemoteSigned -Scope Process` first.*
4.  **設定 .env**：腳本會自動為您開啟記事本 (Notepad) 來編輯 `backend-api/.env` 和 `frontend-vue/.env`。儲存並關閉檔案後，腳本才會繼續。
5.  後端會在新視窗中啟動，前端會在原視窗啟動。

1.  Open PowerShell.
2.  Navigate to the project root.
3.  Run the script:
    ```powershell
    .\local_scripts\local_deploy.ps1
    ```
4.  **Configure .env**: The script will open Notepad for you to edit `backend-api/.env` and `frontend-vue/.env`. Save and close the file to continue.
5.  The backend will start in a new window, and the frontend will start in the current window.

---

## 手動部署 (Manual Deployment)

如果腳本無法運作，您可以手動執行以下步驟：
If the scripts fail, you can manually perform the steps:

### 1. 資料庫設定 (Database Setup)

建立資料庫與資料表。
Create the database and tables.

```sql
/* Run in MySQL Client */
CREATE DATABASE IF NOT EXISTS travel_app_db;
USE travel_app_db;
source local_scripts/init_db.sql;  -- Or copy-paste content from init_db.sql
```

### 2. 後端設定 (Backend Setup)

1.  進入 `backend-api` 目錄。
    ```bash
    cd backend-api
    ```
2.  複製範例環境變數檔。
    ```bash
    cp .env.example .env
    ```
3.  編輯 `.env`，填入正確的資訊 (MySQL user/pass, API Keys 等)。
4.  安裝依賴套件。
    ```bash
    npm install
    ```
5.  啟動伺服器。
    ```bash
    npm start
    ```
    *   *Backend runs on http://localhost:3000*

### 3. 前端設定 (Frontend Setup)

1.  開啟新的終端機視窗，進入 `frontend-vue` 目錄。
    ```bash
    cd frontend-vue
    ```
2.  複製範例環境變數檔。
    ```bash
    cp .env.example .env
    ```
3.  編輯 `.env`，填入 Firebase Config。確保 `VITE_API_BASE_URL=http://localhost:3000`。
4.  安裝依賴套件。
    ```bash
    npm install
    ```
5.  啟動開發伺服器。
    ```bash
    npm run dev
    ```
    *   *Frontend runs on http://localhost:5173*

---

## 環境變數說明 (Environment Variables)

### Backend (`backend-api/.env`)

*   `PORT`: 伺服器端口 (Default: 3000).
*   `DB_HOST`: MySQL 主機 (Default: 127.0.0.1).
*   `DB_PORT`: MySQL 端口 (Default: 3306).
*   `DB_USER`: MySQL 使用者.
*   `DB_PASSWORD`: MySQL 密碼.
*   `DB_NAME`: 資料庫名稱 (travel_app_db).
*   `GEMINI_API_KEY`: Google Gemini AI API 金鑰.
*   `GCP_BUCKET_NAME`: Google Cloud Storage Bucket Name (用於頭像上傳).
*   `GCP_SERVICE_ACCOUNT_JSON`: Google Cloud Service Account 的完整 JSON 內容 (或使用 GOOGLE_APPLICATION_CREDENTIALS).

### Frontend (`frontend-vue/.env`)

*   `VITE_API_BASE_URL`: 後端 API 位址 (e.g., `http://localhost:3000`).
*   `VITE_FIREBASE_*`: Firebase 專案設定 (API Key, Auth Domain, Project ID, etc.).
