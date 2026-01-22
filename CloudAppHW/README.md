# 🐲 DragonFlyX - Cloud Travel Planning Platform

> **Team:** Kenting 🏖️ | **Member:** Po-Chun Lu | **Professor:** Dr. Markus Eilsperger

---

- [中文版本](#中文版本)

## 📋 Table of Contents


- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Directory Structure](#directory-structure)
- [Environment Setup](#environment-setup)
- [Quick Start](#quick-start)
- [API Documentation](#api-documentation)
- [Performance Testing](#performance-testing)
- [Security Notes](#security-notes)


---

## 🌟 Overview

DragonFlyX is a cloud-native social travel management platform with microservice architecture, supporting SaaS B2B business model.

### Key Features

| Icon | Feature | Description |
|------|---------|-------------|
| 🗺️ | Itinerary Management | Create, edit, delete travel itineraries |
| 👥 | Social Interaction | Like, comment, share |
| 🤖 | AI Recommendations | Gemini AI auto-generates travel suggestions |
| 📢 | Destination Ads | Merchant ad placement and management (Wow Factor) |
| 🔐 | Membership | Free / Premium tier differentiation |
| 🔒 | Private Trips | Premium users can hide itineraries |
| 📸 | Avatar Upload | GCS storage for user avatars |

### Wow Factors

1. **Personalized Dynamic Feed** - Real-time display of all user itineraries, visitors can browse
2. **AI Recommendation Engine** - Gemini 3 (Premium) / Gemma 3 (Standard) auto-generates travel suggestions
3. **Destination Management System** - Independent microservice handles ads and offers, supports external link redirection

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Client (Browser)                             │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
┌───────────────────────────────▼─────────────────────────────────────┐
│                  Kubernetes Cluster (Local / GKE)                    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                   Frontend Service (Vue.js + Nginx)             │ │
│  │                            Port: 80                             │ │
│  │   Components: App, AuthAndCreate, ItineraryManager, DynamicFeed,│ │
│  │       ProfileCard, AdBanner, AdminDashboard, MerchantDashboard  │ │
│  └────────────────────────────┬───────────────────────────────────┘ │
│                               │                                      │
│  ┌────────────────────────────▼───────────────────────────────────┐ │
│  │                        API Gateway Layer                        │ │
│  │  ┌──────────────────────┐    ┌─────────────────────────────┐   │ │
│  │  │   Backend API        │    │      Ad-Service             │   │ │
│  │  │   Port: 3000         │    │      Port: 3002             │   │ │
│  │  │   (Express.js)       │    │      (Express.js)           │   │ │
│  │  │                      │    │                             │   │ │
│  │  │  Features:           │    │  Features:                  │   │ │
│  │  │  - Itinerary CRUD    │    │  - Ad CRUD                  │   │ │
│  │  │  - Social Interaction│    │  - Filter by Destination    │   │ │
│  │  │  - AI Suggestions    │    │  - Seed Data Init           │   │ │
│  │  │  - User Auth         │    │                             │   │ │
│  │  │  - Avatar Upload     │    │                             │   │ │
│  │  └──────────┬───────────┘    └──────────────┬──────────────┘   │ │
│  └─────────────┼───────────────────────────────┼──────────────────┘ │
│                │                               │                     │
│  ┌─────────────▼───────────────────────────────▼──────────────────┐ │
│  │                       MySQL Database                            │ │
│  │                         Port: 3306                              │ │
│  │                                                                 │ │
│  │   Tables: travellers, itineraries, destination_ads              │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
                    │               │               │
    ┌───────────────┼───────────────┼───────────────┼────────────────┐
    ▼               ▼               ▼               ▼                │
┌─────────┐   ┌──────────┐   ┌───────────┐   ┌───────────┐          │
│Firebase │   │   GCS    │   │  Gemini   │   │ Firestore │          │
│  Auth   │   │ Storage  │   │    AI     │   │  (Likes/  │          │
│         │   │(Avatars) │   │           │   │ Comments) │          │
└─────────┘   └──────────┘   └───────────┘   └───────────┘          │
```

---

## 🔧 Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Vue.js 3 + Vite + Tailwind CSS |
| **Backend** | Node.js + Express.js |
| **Database** | MySQL + Firebase Firestore |
| **AI** | Google Gemini API (Gemini 3 / Gemma 3) |
| **Storage** | Google Cloud Storage (GCS) |
| **Auth** | Firebase Authentication |
| **Container** | Docker |
| **Orchestration** | Kubernetes (Local + GKE) |
| **IaC** | Terraform + kubectl |
| **Testing** | Locust (Load Testing) |

---

## 📁 Directory Structure

```
CloudAppHW/
│
├── frontend-vue/              # Frontend Vue.js App
│   ├── src/
│   │   ├── App.vue                   # Main app component, routing and state
│   │   ├── firebase.js               # Firebase initialization
│   │   ├── main.js                   # Vue entry point
│   │   ├── style.css                 # Global styles
│   │   ├── components/
│   │   │   ├── AuthAndCreate.vue     # Login/Register/Create Itinerary
│   │   │   ├── ItineraryManager.vue  # Itinerary list and detail view
│   │   │   ├── ProfileCard.vue       # User profile card with avatar upload
│   │   │   ├── DynamicFeed.vue       # Dynamic feed (Wow Factor)
│   │   │   ├── AdBanner.vue          # Ad carousel component
│   │   │   ├── AdminDashboard.vue    # Admin dashboard
│   │   │   ├── MerchantDashboard.vue # Merchant ad management (Wow Factor)
│   │   │   └── GlobalModal.vue       # Global modal component
│   │   └── utils/
│   │       └── modal.js              # Modal state management
│   ├── index.html                    # HTML entry
│   ├── vite.config.js                # Vite configuration
│   ├── nginx.conf                    # Nginx configuration
│   ├── Dockerfile                    # Frontend Docker image
│   ├── .env.example                  # Environment variables template
│   └── package.json                  # Dependencies
│
├── backend-api/               # Backend Express.js API
│   ├── server.js              # Main server
│   │                          # Features: Itinerary CRUD, Social, AI, Auth, Avatar upload
│   ├── Dockerfile             # Backend Docker image
│   ├── .env.example           # Environment variables template
│   └── package.json           # Dependencies
│
├── ad-service/                # Ad Microservice (Wow Factor)
│   ├── server.js              # Ad CRUD API + Seed data
│   ├── Dockerfile             # Ad service Docker image
│   ├── .env.example           # Environment variables template
│   └── package.json           # Dependencies
│
├── k8s/                       # Local Kubernetes configs
│   ├── backend.yaml           # Backend Deployment + Service
│   ├── frontend.yaml          # Frontend Deployment + Service
│   ├── ad-service.yaml        # Ad-Service Deployment + Service
│   ├── mysql.yaml             # MySQL StatefulSet + PVC
│   ├── mysql-init.yaml        # MySQL Init ConfigMap
│   ├── backend-secrets.yaml   # API Keys and Secrets
│   └── backend-secrets.example.yaml  # Secrets template
│
├── k8s-gke/                   # GKE Kubernetes configs
│   └── (Same structure as k8s/)
│
├── terraform/                 # IaC Infrastructure
│   ├── main.tf                # GKE cluster configuration
│   │                          # Defines: GKE Cluster, Node Pool, APIs
│   ├── variables.tf           # Variable definitions
│   ├── terraform.tfvars.example  # Variables template
│   ├── credentials.json       # GCP service account key
│   └── Deployment_Logs/       # Deployment logs
│
├── locust/                    # Load testing scripts
│   ├── locustfile.py          # Main load test script
│   │                          # Tests: Feed browsing, Detail view, Likes, Comments, Health
│   ├── quote.py               # Legacy test script (kept)
│   └── start.txt              # Start instructions
│
├── local_scripts/             # Local deployment scripts
│   ├── local_deploy.sh        # Unix/Mac deploy script
│   ├── local_deploy.ps1       # Windows PowerShell deploy script
│   └── init_db.sql            # Database init SQL
│
├── dummy_data.sql             # Sample data
│
├── functions.txt              # Requirements specification
├── PROGRESS_CHECKLIST.md      # Feature completion checklist
├── PRESENTATION_DRAFT.md      # Presentation draft
├── DEMO_SCRIPT.md             # Demo script
├── K8S_DEPLOY_GUIDE.md        # GKE deployment guide
├── K8S_DEPLOY_GUIDE_LOCAL.md  # Local K8s deployment guide
└── TERRAFORM_DEPLOY_GUIDE.md  # Terraform deployment guide
```

---

## ⚙️ Environment Setup

> [!IMPORTANT]
> The following files are **excluded by `.gitignore`** and must be created manually before deployment.

---

### 1. Backend API - `./backend-api/.env`

Copy from `./backend-api/.env.example` and fill in the values.

```env
PORT=3000
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_root_password
DB_NAME=travel_app_db

# Google Gemini API Key
GEMINI_API_KEY=

# Google Cloud Storage Bucket Name (for avatars)
GCP_BUCKET_NAME=

# Option 1: Paste the full JSON content here (single line)
GCP_SERVICE_ACCOUNT_JSON=

# Option 2: Leave GCP_SERVICE_ACCOUNT_JSON empty and use:
# export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account.json"
```

---

### 2. Frontend Vue - `./frontend-vue/.env`

Copy from `./frontend-vue/.env.example` and fill in the values.

```env
VITE_API_BASE_URL=http://localhost:3000

# Firebase Config
VITE_FIREBASE_API_KEY=
VITE_FIREBASE_AUTH_DOMAIN=
VITE_FIREBASE_PROJECT_ID=
VITE_FIREBASE_APP_ID=
VITE_FIREBASE_STORAGE_BUCKET=
VITE_MEASUREMENTID=
```

---

### 3. Ad Service - `./ad-service/.env`

Copy from `./ad-service/.env.example` and fill in the values.

```env
PORT=3002
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=secret
DB_NAME=travel_db
DB_PORT=3306
```

---

### 4. Terraform - `./terraform/terraform.tfvars`

Copy from `./terraform/terraform.tfvars.example` and fill in the values.

```hcl
# GCP Project ID
project_id = "your-project-id-here"

# Service Account JSON key file path
credentials_file = "credentials.json"

# Region setting
region = "europe-west1"

# Cluster settings
cluster_name  = "cloud-app-cluster"
environment   = "dev"
k8s_namespace = "default"

# Node settings
machine_type    = "e2-small"
node_count      = 2
max_node_count  = 4
use_preemptible = true

# Application secrets
gemini_api_key           = ""
gcp_service_account_json = ""
```

---

### 5. Terraform - `./terraform/credentials.json`

Download from **Google Cloud Console → IAM → Service Accounts**.

---

### 6. Frontend SSL - `./frontend-vue/nginx.key` & `nginx.crt`

SSL certificate files for HTTPS. Generate self-signed certificates:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx.key -out nginx.crt
```

---

### 7. Kubernetes Secrets - `./k8s/backend-secrets.yaml`

Copy from `./k8s/backend-secrets.example.yaml` and fill in Base64-encoded values.

---

## 🚀 Quick Start

### Local K8s Deployment

```bash
# 1. Build Docker Images
cd CloudAppHW
docker build -t backend-api:latest ./backend-api
docker build -t ad-service:latest ./ad-service
docker build -t frontend-vue:latest ./frontend-vue

# 2. Deploy to Kubernetes
kubectl apply -f k8s/

# 3. Check Status
kubectl get pods
kubectl get services

# 4. Access Application
# Frontend: http://localhost:30080
# Backend API: http://localhost:30000
```

### GKE Deployment

```bash
# 1. Create GKE Cluster with Terraform
cd terraform
terraform init
terraform apply

# 2. Connect to GKE Cluster
gcloud container clusters get-credentials CLUSTER_NAME --region REGION --project PROJECT_ID

# 3. Build and push to GCR
docker build --platform linux/amd64 -t gcr.io/PROJECT_ID/backend-api:latest ./backend-api
docker build --platform linux/amd64 -t gcr.io/PROJECT_ID/ad-service:latest ./ad-service
docker build --platform linux/amd64 -t gcr.io/PROJECT_ID/frontend-vue:latest ./frontend-vue

docker push gcr.io/PROJECT_ID/backend-api:latest
docker push gcr.io/PROJECT_ID/ad-service:latest
docker push gcr.io/PROJECT_ID/frontend-vue:latest

# 4. Deploy to GKE
kubectl apply -f k8s-gke/
kubectl rollout restart deployment backend ad-service frontend
```

---

## 📡 API Documentation

### Backend API (Port 3000)

| Method | Endpoint | Description |
|--------|----------|-------------|
| **Itinerary** | | |
| POST | `/api/itineraries` | Create itinerary |
| GET | `/api/itineraries/feed` | Get public feed |
| GET | `/api/itineraries/detail/:id` | Get itinerary detail |
| GET | `/api/itineraries/by-email/:email` | Get user's itineraries |
| PUT | `/api/itineraries/:id` | Update itinerary |
| DELETE | `/api/itineraries/:id` | Delete itinerary |
| **Social** | | |
| POST | `/api/itineraries/:id/like/toggle` | Toggle like |
| GET | `/api/itineraries/:id/like/count` | Get like count |
| GET | `/api/itineraries/:id/like/list` | Get like list |
| GET | `/api/itineraries/:id/comments` | Get comments |
| POST | `/api/itineraries/:id/comments` | Add comment |
| DELETE | `/api/itineraries/:id/comments/:commentId` | Delete comment |
| **User** | | |
| POST | `/api/travellers/ensure` | Ensure user exists |
| POST | `/api/upload-avatar` | Upload avatar |
| GET | `/api/avatar/:email` | Get avatar URL |
| **Admin** | | |
| GET | `/api/admin/users` | Get all users |
| PUT | `/api/admin/users/:id/level` | Update user level |
| **System** | | |
| GET | `/health` | Health check |

### Ad-Service API (Port 3002)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/ads` | Get all ads |
| GET | `/api/ads?destination=` | Filter by destination |
| GET | `/api/ads/:id` | Get single ad |
| POST | `/api/ads` | Create ad |
| PUT | `/api/ads/:id` | Update ad |
| DELETE | `/api/ads/:id` | Delete ad |
| GET | `/health` | Health check |

---

## 📊 Performance Testing

### Run Load Test

```bash
cd locust
pip install locust

# Local testing
locust -f locustfile.py --host=http://localhost:30080

# GKE testing
locust -f locustfile.py --host=http://EXTERNAL_IP:80

# Headless mode
locust -f locustfile.py --host=http://localhost:30080 \
  --users 50 --spawn-rate 5 --run-time 60s --headless
```

### Test Coverage

| Test Type | Weight |
|-----------|--------|
| Browse Feed | 3x |
| View Itinerary Detail | 2x |
| Create Itinerary (No Auth) | 1x |
| Get Likes Count | 1x |
| Get Comments | 1x |
| Health Check | 1x |

---

## 🔐 Security Notes

- Firebase Authentication for user identity verification
- API endpoints use JWT Token verification
- Sensitive information stored in Kubernetes Secrets
- Admin functionality limited to first registered user (automatically becomes admin)

---

## 📄 License

This project is for educational purposes - HTWG Cloud Application Development Course.

---
---

# 中文版本

# 🐲 DragonFlyX - 雲端旅遊規劃平台

> **團隊:** Kenting 🏖️ | **成員:** 盧柏均 | **教授:** Dr. Markus Eilsperger

---

## 📋 目錄

- [專案概述](#專案概述)
- [系統架構](#系統架構)
- [技術棧](#技術棧)
- [目錄結構](#目錄結構-1)
- [環境設定](#環境設定)
- [快速開始](#快速開始)
- [API 文件](#api-文件)
- [效能測試](#效能測試)
- [安全性說明](#安全性說明)

---

## 🌟 專案概述

DragonFlyX 是一個雲端原生的社交旅遊管理平台，採用微服務架構，支援 SaaS B2B 商業模式。

### 主要功能

| 圖示 | 功能 | 說明 |
|------|------|------|
| 🗺️ | 行程管理 | 建立、編輯、刪除旅遊行程 |
| 👥 | 社交互動 | 按讚、留言、分享 |
| 🤖 | AI 建議 | Gemini AI 自動生成旅遊建議 |
| 📢 | 目的地廣告 | 商家廣告投放與管理 (Wow Factor) |
| 🔐 | 會員系統 | Free / Premium 等級區分 |
| 🔒 | 私人行程 | Premium 用戶可隱藏行程 |
| 📸 | 頭像上傳 | GCS 儲存用戶頭像 |

### Wow 因素

1. **個人化動態牆** - 即時顯示所有用戶行程，訪客可瀏覽
2. **AI 推薦引擎** - Gemini 3 (Premium) / Gemma 3 (Standard) 自動生成旅遊建議
3. **目的地管理系統** - 獨立微服務處理廣告和優惠，支援外部連結跳轉

---

## 🏗️ 系統架構

```
┌─────────────────────────────────────────────────────────────────────┐
│                          客戶端 (瀏覽器)                              │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
┌───────────────────────────────▼─────────────────────────────────────┐
│                    Kubernetes 叢集 (本地 / GKE)                       │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                     前端服務 (Vue.js + Nginx)                    │ │
│  │                         Port: 80                                │ │
│  │   元件: App, AuthAndCreate, ItineraryManager, DynamicFeed,     │ │
│  │         ProfileCard, AdBanner, AdminDashboard, MerchantDashboard│ │
│  └────────────────────────────┬───────────────────────────────────┘ │
│                               │                                      │
│  ┌────────────────────────────▼───────────────────────────────────┐ │
│  │                         API 閘道層                               │ │
│  │  ┌──────────────────────┐    ┌─────────────────────────────┐   │ │
│  │  │   Backend API        │    │      Ad-Service             │   │ │
│  │  │   Port: 3000         │    │      Port: 3002             │   │ │
│  │  │   (Express.js)       │    │      (Express.js)           │   │ │
│  │  │                      │    │                             │   │ │
│  │  │  功能:               │    │  功能:                       │   │ │
│  │  │  - 行程 CRUD         │    │  - 廣告 CRUD                 │   │ │
│  │  │  - 社交互動          │    │  - 依目的地篩選              │   │ │
│  │  │  - AI 建議生成       │    │  - 種子資料初始化            │   │ │
│  │  │  - 用戶認證          │    │                             │   │ │
│  │  │  - 頭像上傳          │    │                             │   │ │
│  │  └──────────┬───────────┘    └──────────────┬──────────────┘   │ │
│  └─────────────┼───────────────────────────────┼──────────────────┘ │
│                │                               │                     │
│  ┌─────────────▼───────────────────────────────▼──────────────────┐ │
│  │                       MySQL Database                            │ │
│  │                         Port: 3306                              │ │
│  │                                                                 │ │
│  │   資料表: travellers, itineraries, destination_ads              │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
                    │               │               │
    ┌───────────────┼───────────────┼───────────────┼────────────────┐
    ▼               ▼               ▼               ▼                │
┌─────────┐   ┌──────────┐   ┌───────────┐   ┌───────────┐          │
│Firebase │   │  GCS     │   │  Gemini   │   │ Firestore │          │
│  Auth   │   │ Storage  │   │    AI     │   │  (按讚/   │          │
│         │   │ (頭像)   │   │           │   │  留言)    │          │
└─────────┘   └──────────┘   └───────────┘   └───────────┘          │
```

---

## 🔧 技術棧

| 層級 | 技術 |
|------|------|
| **前端** | Vue.js 3 + Vite + Tailwind CSS |
| **後端** | Node.js + Express.js |
| **資料庫** | MySQL + Firebase Firestore |
| **AI** | Google Gemini API (Gemini 3 / Gemma 3) |
| **儲存** | Google Cloud Storage (GCS) |
| **認證** | Firebase Authentication |
| **容器** | Docker |
| **編排** | Kubernetes (本地 + GKE) |
| **IaC** | Terraform + kubectl |
| **測試** | Locust (負載測試) |

---

## 📁 目錄結構

```
CloudAppHW/
│
├── frontend-vue/              # 前端 Vue.js 應用
│   ├── src/
│   │   ├── App.vue                   # 主應用元件，路由和狀態管理
│   │   ├── firebase.js               # Firebase 初始化
│   │   ├── main.js                   # Vue 進入點
│   │   ├── style.css                 # 全域樣式
│   │   ├── components/
│   │   │   ├── AuthAndCreate.vue     # 登入/註冊/建立行程
│   │   │   ├── ItineraryManager.vue  # 行程列表和詳情檢視
│   │   │   ├── ProfileCard.vue       # 用戶資料卡片+頭像上傳
│   │   │   ├── DynamicFeed.vue       # 動態牆 (Wow Factor)
│   │   │   ├── AdBanner.vue          # 廣告輪播元件
│   │   │   ├── AdminDashboard.vue    # 管理員後台
│   │   │   ├── MerchantDashboard.vue # 商家廣告管理 (Wow Factor)
│   │   │   └── GlobalModal.vue       # 全域彈窗元件
│   │   └── utils/
│   │       └── modal.js              # 彈窗狀態管理
│   ├── index.html                    # HTML 入口
│   ├── vite.config.js                # Vite 配置
│   ├── nginx.conf                    # Nginx 配置
│   ├── Dockerfile                    # 前端 Docker 映像
│   ├── .env.example                  # 環境變數範本
│   └── package.json                  # 依賴宣告
│
├── backend-api/               # 後端 Express.js API
│   ├── server.js              # 主伺服器
│   │                          # 功能: 行程 CRUD, 社交互動, AI 建議, 用戶認證, 頭像上傳
│   ├── Dockerfile             # 後端 Docker 映像
│   ├── .env.example           # 環境變數範本
│   └── package.json           # 依賴宣告
│
├── ad-service/                # 廣告微服務 (Wow Factor)
│   ├── server.js              # 廣告 CRUD API + 種子資料
│   ├── Dockerfile             # 廣告服務 Docker 映像
│   ├── .env.example           # 環境變數範本
│   └── package.json           # 依賴宣告
│
├── k8s/                       # 本地 Kubernetes 設定
│   ├── backend.yaml           # Backend Deployment + Service
│   ├── frontend.yaml          # Frontend Deployment + Service
│   ├── ad-service.yaml        # Ad-Service Deployment + Service
│   ├── mysql.yaml             # MySQL StatefulSet + PVC
│   ├── mysql-init.yaml        # MySQL Init ConfigMap
│   ├── backend-secrets.yaml   # API Keys and Secrets
│   └── backend-secrets.example.yaml  # Secrets 範本
│
├── k8s-gke/                   # GKE Kubernetes 設定
│   └── (同上結構)
│
├── terraform/                 # IaC 基礎設施
│   ├── main.tf                # GKE 叢集配置
│   │                          # 定義: GKE Cluster, Node Pool, APIs
│   ├── variables.tf           # 變數定義
│   ├── terraform.tfvars.example  # 變數值範本
│   ├── credentials.json       # GCP 服務帳戶金鑰
│   └── Deployment_Logs/       # 部署日誌
│
├── locust/                    # 負載測試腳本
│   ├── locustfile.py          # 主要負載測試腳本
│   │                          # 測試: 動態牆瀏覽, 行程詳情, 按讚, 留言, 健康檢查
│   ├── quote.py               # 舊版測試腳本 (保留)
│   └── start.txt              # 啟動說明
│
├── local_scripts/             # 本地部署腳本
│   ├── local_deploy.sh        # Unix/Mac 部署腳本
│   ├── local_deploy.ps1       # Windows PowerShell 部署腳本
│   └── init_db.sql            # 資料庫初始化 SQL
│
├── dummy_data.sql             # 範例資料
│
├── functions.txt              # 需求規格文件
├── PROGRESS_CHECKLIST.md      # 功能完成度檢查
├── PRESENTATION_DRAFT.md      # 簡報草稿
├── DEMO_SCRIPT.md             # Demo 演示腳本
├── K8S_DEPLOY_GUIDE.md        # GKE 部署指南
├── K8S_DEPLOY_GUIDE_LOCAL.md  # 本地 K8s 部署指南
└── TERRAFORM_DEPLOY_GUIDE.md  # Terraform 部署指南
```

---

## ⚙️ 環境設定

> [!IMPORTANT]
> 以下檔案已被 `.gitignore` 忽略，需手動建立後才能部署。

---

### 1. Backend API - `./backend-api/.env`

複製 `./backend-api/.env.example` 並填入實際值。

```env
PORT=3000
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_root_password
DB_NAME=travel_app_db

# Google Gemini API Key
GEMINI_API_KEY=

# Google Cloud Storage Bucket Name (頭像儲存)
GCP_BUCKET_NAME=

# 選項 1: 將完整 JSON 內容貼在此處 (單行)
GCP_SERVICE_ACCOUNT_JSON=

# 選項 2: 將上方留空，並使用:
# export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account.json"
```

---

### 2. Frontend Vue - `./frontend-vue/.env`

複製 `./frontend-vue/.env.example` 並填入實際值。

```env
VITE_API_BASE_URL=http://localhost:3000

# Firebase 設定
VITE_FIREBASE_API_KEY=
VITE_FIREBASE_AUTH_DOMAIN=
VITE_FIREBASE_PROJECT_ID=
VITE_FIREBASE_APP_ID=
VITE_FIREBASE_STORAGE_BUCKET=
VITE_MEASUREMENTID=
```

---

### 3. Ad Service - `./ad-service/.env`

複製 `./ad-service/.env.example` 並填入實際值。

```env
PORT=3002
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=secret
DB_NAME=travel_db
DB_PORT=3306
```

---

### 4. Terraform - `./terraform/terraform.tfvars`

複製 `./terraform/terraform.tfvars.example` 並填入實際值。

```hcl
# GCP Project ID
project_id = "your-project-id-here"

# Service Account JSON 金鑰檔案路徑
credentials_file = "credentials.json"

# 區域設定
region = "europe-west1"

# Cluster 設定
cluster_name  = "cloud-app-cluster"
environment   = "dev"
k8s_namespace = "default"

# 節點設定
machine_type    = "e2-small"
node_count      = 2
max_node_count  = 4
use_preemptible = true

# 應用程式機密
gemini_api_key           = ""
gcp_service_account_json = ""
```

---

### 5. Terraform - `./terraform/credentials.json`

從 **Google Cloud Console → IAM → Service Accounts** 下載 JSON 金鑰檔案並放置於此目錄。

---

### 6. Frontend SSL - `./frontend-vue/nginx.key` & `nginx.crt`

SSL 憑證檔案，用於 HTTPS 設定。可使用 OpenSSL 生成自簽憑證：

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx.key -out nginx.crt
```

---

### 7. Kubernetes Secrets - `./k8s/backend-secrets.yaml`

複製 `./k8s/backend-secrets.example.yaml` 並填入 Base64 編碼後的值。

---

## 🚀 快速開始

### 本地 Kubernetes 部署

```bash
# 1. 建置 Docker Images
cd CloudAppHW
docker build -t backend-api:latest ./backend-api
docker build -t ad-service:latest ./ad-service
docker build -t frontend-vue:latest ./frontend-vue

# 2. 部署到 Kubernetes
kubectl apply -f k8s/

# 3. 檢查狀態
kubectl get pods
kubectl get services

# 4. 存取應用
# 前端: http://localhost:30080
# 後端 API: http://localhost:30000
```

### GKE 部署

```bash
# 1. 使用 Terraform 建立 GKE Cluster
cd terraform
terraform init
terraform apply

# 2. 連接到 GKE Cluster
gcloud container clusters get-credentials CLUSTER_NAME --region REGION --project PROJECT_ID

# 3. 建置並推送到 GCR
docker build --platform linux/amd64 -t gcr.io/PROJECT_ID/backend-api:latest ./backend-api
docker build --platform linux/amd64 -t gcr.io/PROJECT_ID/ad-service:latest ./ad-service
docker build --platform linux/amd64 -t gcr.io/PROJECT_ID/frontend-vue:latest ./frontend-vue

docker push gcr.io/PROJECT_ID/backend-api:latest
docker push gcr.io/PROJECT_ID/ad-service:latest
docker push gcr.io/PROJECT_ID/frontend-vue:latest

# 4. 部署到 GKE
kubectl apply -f k8s-gke/
kubectl rollout restart deployment backend ad-service frontend
```

---

## 📡 API 文件

### Backend API (Port 3000)

| 方法 | 端點 | 說明 |
|------|------|------|
| **行程管理** | | |
| POST | `/api/itineraries` | 建立行程 |
| GET | `/api/itineraries/feed` | 取得公開動態牆 |
| GET | `/api/itineraries/detail/:id` | 取得行程詳情 |
| GET | `/api/itineraries/by-email/:email` | 取得用戶行程 |
| PUT | `/api/itineraries/:id` | 更新行程 |
| DELETE | `/api/itineraries/:id` | 刪除行程 |
| **社交功能** | | |
| POST | `/api/itineraries/:id/like/toggle` | 切換按讚 |
| GET | `/api/itineraries/:id/like/count` | 取得按讚數 |
| GET | `/api/itineraries/:id/like/list` | 取得按讚列表 |
| GET | `/api/itineraries/:id/comments` | 取得留言 |
| POST | `/api/itineraries/:id/comments` | 新增留言 |
| DELETE | `/api/itineraries/:id/comments/:commentId` | 刪除留言 |
| **用戶管理** | | |
| POST | `/api/travellers/ensure` | 確保用戶存在 |
| POST | `/api/upload-avatar` | 上傳頭像 |
| GET | `/api/avatar/:email` | 取得頭像 URL |
| **管理員** | | |
| GET | `/api/admin/users` | 取得所有用戶 |
| PUT | `/api/admin/users/:id/level` | 更新用戶等級 |
| **系統** | | |
| GET | `/health` | 健康檢查 |

### Ad-Service API (Port 3002)

| 方法 | 端點 | 說明 |
|------|------|------|
| GET | `/api/ads` | 取得所有廣告 |
| GET | `/api/ads?destination=` | 依目的地篩選 |
| GET | `/api/ads/:id` | 取得單一廣告 |
| POST | `/api/ads` | 建立廣告 |
| PUT | `/api/ads/:id` | 更新廣告 |
| DELETE | `/api/ads/:id` | 刪除廣告 |
| GET | `/health` | 健康檢查 |

---

## 📊 效能測試

### 執行負載測試

```bash
cd locust
pip install locust

# 本地測試
locust -f locustfile.py --host=http://localhost:30080

# GKE 測試
locust -f locustfile.py --host=http://EXTERNAL_IP:80

# 無頭模式
locust -f locustfile.py --host=http://localhost:30080 \
  --users 50 --spawn-rate 5 --run-time 60s --headless
```

### 測試涵蓋範圍

| 測試類型 | 權重 |
|----------|------|
| 瀏覽動態牆 | 3x |
| 查看行程詳情 | 2x |
| 建立行程 (無授權) | 1x |
| 取得按讚數 | 1x |
| 取得留言 | 1x |
| 健康檢查 | 1x |

---

## 🔐 安全性說明

- Firebase Authentication 用於用戶身份驗證
- API 端點使用 JWT Token 驗證
- 敏感資訊存放於 Kubernetes Secrets
- Admin 功能僅限第一個註冊用戶 (自動成為管理員)

---

## 📄 授權

此專案為教育用途 - HTWG 雲端應用開發課程。
