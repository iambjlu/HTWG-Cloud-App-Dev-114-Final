# 📋 Cloud-native Milestone - 功能完成度檢查

> 根據 `functions.txt` 需求文件，檢查專案完成狀態
> 
> 最後更新：2026-01-21

---

## 🎯 整體評估

| 評估項目 | 狀態 | 說明 |
|---------|------|------|
| **Wow 因素數量** | ✅ 3+ | 動態牆 + AI 推薦 + Ad Service (目的地管理) |
| **微服務架構** | ✅ | Frontend + Backend + Ad-Service + MySQL |
| **獨立微服務 Wow** | ✅ | Ad-Service 獨立部署於 Port 3002 |
| **Kubernetes 部署** | ✅ | k8s/ 和 k8s-gke/ 完整設定 |
| **IaC 自動化** | ✅ | Terraform + kubectl apply |
| **負載測試腳本** | ✅ | locust/locustfile.py |

---

## 📦 SaaS B2B 方案架構

### 會員等級系統
| 項目 | 狀態 | 實作位置 |
|------|------|----------|
| Free（免費）方案 | ✅ | `membership_tier = 'Free'` (預設) |
| Standard（標準）方案 | ✅ | `membership_tier = 'Premium'` |
| Enterprise（企業級）方案 | ⬜ | 未實作 |
| 會員等級 UI 顯示 | ✅ | `ProfileCard.vue` 顯示等級徽章 |
| 管理員升級用戶 | ✅ | `AdminDashboard.vue` |
| Premium 專屬功能 | ✅ | 私人行程、隱藏廣告、Gemini 3 AI |

---

## ✈️ 行程管理 (Itinerary Management)

> 里程碑 1 的基本必備功能

| 項目 | 狀態 | 實作位置 |
|------|------|----------|
| 建立行程 | ✅ | `POST /api/itineraries` |
| 編輯行程 | ✅ | `PUT /api/itineraries/:id` |
| 刪除行程 | ✅ | `DELETE /api/itineraries/:id` |
| 檢視行程詳情 | ✅ | `GET /api/itineraries/detail/:id` |
| 行程清單 | ✅ | `GET /api/itineraries/by-email/:email` |
| 目的地 | ✅ | `destination` 欄位 |
| 日期範圍 | ✅ | `start_date`, `end_date` |
| 簡短描述 | ✅ | `short_description` (80 字限制) |
| 詳細描述 | ✅ | `detail_description` |
| 私人行程 | ✅ | `is_private` 欄位 (Premium 專屬) |
| 複製行程 | ✅ | `ItineraryManager.vue` → `cloneTrip()` |
| 出發機場 | ⬜ | 未實作 (選配) |
| 航班號碼 | ⬜ | 未實作 (選配) |

---

## 👥 社交互動 (Social Interaction)

> 獨立服務實作 → 使用 **Firebase Firestore**

| 項目 | 狀態 | 實作位置 |
|------|------|----------|
| 按讚功能 | ✅ | `POST /api/itineraries/:id/like/toggle` |
| 按讚數量 | ✅ | `GET /api/itineraries/:id/like/count` |
| 按讚清單 | ✅ | `GET /api/itineraries/:id/like/list` |
| 留言功能 | ✅ | `POST /api/itineraries/:id/comments` |
| 留言清單 | ✅ | `GET /api/itineraries/:id/comments` |
| 刪除自己的留言 | ✅ | `DELETE /api/itineraries/:id/comments/:commentId` |
| 查看其他用戶頁面 | ✅ | `?profile=email@example.com` URL 參數 |
| 訪客模式瀏覽 | ✅ | 未登入可看公開內容和動態牆 |
| 分享連結 | ✅ | `ItineraryManager.vue` → `shareTrip()` |

### Wow 因素

| 項目 | 狀態 | 實作位置 |
|------|------|----------|
| **🌟 個人化即時動態牆** | ✅ | `DynamicFeed.vue` - 顯示所有公開行程 |
| 個人化電子報 | ⬜ | 未實作 (選配) |
| **🌟 AI 推薦引擎** | ✅ | `Gemini 3 / Gemma 3` 自動產生旅遊建議 |

---

## 🏝️ 目的地管理 (Destination Management) - Wow 因素

> 獨立微服務：**Ad-Service** (Port 3002)

| 項目 | 狀態 | 實作位置 |
|------|------|----------|
| **🌟 購買廣告版位** | ✅ | `POST /api/ads` |
| **🌟 特別優惠管理** | ✅ | `discount_code` 欄位 |
| **🌟 景點折扣行銷** | ✅ | `external_url` 外部連結跳轉 |
| 廣告 CRUD | ✅ | 完整 Create/Read/Update/Delete |
| 依目的地篩選廣告 | ✅ | `GET /api/ads?destination=Kyoto` |
| 廣告圖片 | ✅ | `image_url` 欄位 |
| 商家後台介面 | ✅ | `MerchantDashboard.vue` |
| 廣告輪播展示 | ✅ | `AdBanner.vue` 在行程詳情頁和動態牆 |
| 預設種子資料 | ✅ | 10 筆範例廣告 (Kyoto, Tokyo, Paris, Kenting, Taitung 等) |
| 外部連結跳轉 | ✅ | `target="_blank"` 新視窗開啟 |

---

## 🌍 旅遊資訊 (Travel Information) - Wow 因素 (選配)

| 項目 | 狀態 | 說明 |
|------|------|------|
| 航班時刻變更解析 | ⬜ | 未實作 (需航班 API) |
| 官方旅遊警示 | ⬜ | 未實作 |
| **🌟 天氣資訊處理** | ⚠️ 部分 | AI 建議包含季節/天氣提示 |

---

## 🔄 非同步工作流程 (Async Workflows)

> 每個 Wow 因素都採用非同步工作流程，提升資料處理效率

### AI 推薦引擎非同步處理
| 項目 | 狀態 | 實作位置 |
|------|------|----------|
| Soft Timeout 機制 | ✅ | `server.js:500` - 4 秒前景超時 |
| Background Fallback | ✅ | `server.js:525-546` - 超時後背景處理 |
| Firestore 狀態儲存 | ✅ | `aiSuggestions/{id}` collection |
| Frontend Polling | ✅ | `ItineraryManager.vue:47-62` - 每 2 秒輪詢 |
| Max Tries 控制 | ✅ | 最多輪詢 8 次 (16 秒) |
| 用戶開關控制 | ✅ | `enable_ai: false` 可關閉 AI |

### 社交功能非同步處理
| 項目 | 狀態 | 實作位置 |
|------|------|----------|
| Optimistic UI Update | ✅ | 按讚/留言立即更新 UI |
| Parallel Loading | ✅ | `loadLikesForVisibleTrips()` 平行載入 |
| Background Cleanup | ✅ | 刪除行程時背景清理 Firestore |

### 廣告服務非同步處理
| 項目 | 狀態 | 實作位置 |
|------|------|----------|
| Fallback Strategy | ✅ | 無目的地廣告時隨機推薦 |
| Watch Reactive | ✅ | 目的地變更時自動重載 |
| Seed Data Init | ✅ | 服務啟動時非同步初始化 |

---

## ⚙️ 技術需求 (Technical Requirements)

### 微服務架構 & 12-Factor
| 項目 | 狀態 | 說明 |
|------|------|------|
| 微服務架構 | ✅ | 4 個服務：Frontend, Backend, Ad-Service, MySQL |
| 程式碼庫 (Codebase) | ✅ | Git 版控 |
| 相依性 (Dependencies) | ✅ | package.json 明確宣告 |
| 設定 (Config) | ✅ | 環境變數 (.env, K8s Secrets) |
| 後端服務 (Backing Services) | ✅ | MySQL, Firebase, GCS, Gemini |
| 建置/發布/執行分離 | ✅ | Docker build → K8s apply → rollout |
| 無狀態程序 (Processes) | ✅ | Pod 無狀態，資料存 MySQL/Firestore |
| 埠口繫結 (Port Binding) | ✅ | 3000, 3002, 80 |
| 並行 (Concurrency) | ✅ | K8s replicas 可調整 |
| 快速啟動/優雅關閉 | ✅ | Container 秒級啟動 |
| 開發/正式環境一致 | ✅ | Docker 確保環境一致 |
| 日誌 (Logs) | ✅ | JSON 結構化日誌輸出至 stdout |
| 管理程序 (Admin) | ✅ | AdminDashboard 管理介面 |

### Kubernetes 部署
| 項目 | 狀態 | 說明 |
|------|------|------|
| 核心元件部署 K8s | ✅ | 全部 4 個服務都在 K8s |
| 本地 K8s (OrbStack) | ✅ | `k8s/` 目錄 |
| GKE 部署 | ✅ | `k8s-gke/` 目錄 |
| PersistentVolume | ✅ | MySQL 資料持久化 |
| ConfigMap | ✅ | mysql-init-scripts |
| Secrets | ✅ | backend-secrets (API Keys) |
| LoadBalancer Service | ✅ | Frontend 對外服務 |
| HPA 自動擴展 | ✅ | 已配置 (待驗證) |

### IaC 自動化
| 項目 | 狀態 | 說明 |
|------|------|------|
| 部署自動化 | ✅ | `kubectl apply -f k8s/` |
| Dockerfile | ✅ | 三個服務都有 Dockerfile |
| 部署腳本 | ✅ | `local_deploy.sh`, `local_deploy.ps1` |
| Terraform GKE | ✅ | `terraform/main.tf` (GKE Cluster + Node Pool) |
| 重部署 Workflow | ✅ | `.agent/workflows/redeploy_k8s.md` |

### 效能測試
| 項目 | 狀態 | 說明 |
|------|------|------|
| 效能測試腳本 | ✅ | `locust/locustfile.py` (Locust) |
| 測試涵蓋範圍 | ✅ | Feed, Detail, Likes, Comments, Health |
| 效能測試報告 | ⚠️ 部分 | 需執行並產生報告 |
| 測試資料集 | ✅ | `dummy_data.sql` + Ad-Service 種子資料 |

---

## 📊 完成度總結

### 功能區域完成度

| 區域 | 完成度 | 說明 |
|------|--------|------|
| 行程管理 | 95% | 完整 CRUD + 複製 + 私人行程 |
| 社交互動 | 95% | 完整按讚/留言/分享，缺電子報 |
| 目的地管理 | **100%** | ✅ 完整 Wow 因素 + 外部連結 |
| AI 推薦 | **100%** | ✅ 雙模型支援 (Gemini 3 / Gemma 3) |
| 技術需求 | 95% | 完整測試腳本，待產生報告 |

### Wow 因素清單

| Wow 因素 | 狀態 | 微服務 | 類別 |
|----------|------|--------|------|
| ✅ 個人化即時動態牆 | 完成 | Frontend | 社交互動 |
| ✅ AI 推薦引擎 | 完成 | Backend (Gemini) | 社交互動 |
| ✅ 目的地廣告版位 | 完成 | **Ad-Service** | 目的地管理 |
| ✅ 特別優惠/折扣 | 完成 | **Ad-Service** | 目的地管理 |
| ✅ 外部連結行銷 | 完成 | **Ad-Service** | 目的地管理 |
| ⬜ 個人化電子報 | 未完成 | - | 社交互動 (選配) |
| ⬜ 航班時刻變更 | 未完成 | - | 旅遊資訊 (選配) |
| ⬜ 旅遊警示 | 未完成 | - | 旅遊資訊 (選配) |

### 評級

```
🏆 評級：非常好 (Very Good)

理由：
✅ 實作 3+ 個 Wow 因素 (動態牆 + AI 推薦 + 目的地管理全套)
✅ Wow 因素分布在不同微服務 (Backend AI + Ad-Service)
✅ 完整 Kubernetes 部署 (Local + GKE)
✅ IaC 自動化 (Terraform + kubectl)
✅ 負載測試腳本 (Locust)
✅ 完整商家後台 (MerchantDashboard)
✅ 外部連結跳轉功能
```

---

## 📝 建議改進項目

### 優先級高 (已完成 ✅)
1. ~~**效能測試腳本**~~ - ✅ Locust 已實作
2. ~~**外部連結功能**~~ - ✅ Ad-Service external_url 已實作

### 優先級中 (可選)
3. **效能測試報告** - 執行 Locust 並匯出報告文件
4. **航班資訊欄位** - 在 itineraries 表加入 `departure_airport`, `flight_number`
5. **非同步工作流程控制** - 使用 Redis Queue 或 Cloud Tasks

### 優先級低 (進階功能)
6. **個人化電子報** - 定期發送 Email (SendGrid / Mailgun)
7. **旅遊警示** - 整合外部 API (Travel Advisory)
8. **航班時刻變更** - 整合 FlightAware API
9. **Enterprise 方案** - 高度客製化功能

---

## 🔗 相關文件

- [README.md](README.md) - 主要說明文件
- [K8S_DEPLOY_GUIDE.md](K8S_DEPLOY_GUIDE.md) - GKE 部署指南
- [K8S_DEPLOY_GUIDE_LOCAL.md](K8S_DEPLOY_GUIDE_LOCAL.md) - 本地 K8s 部署指南
- [TERRAFORM_DEPLOY_GUIDE.md](TERRAFORM_DEPLOY_GUIDE.md) - Terraform 部署指南
- [PRESENTATION_DRAFT.md](PRESENTATION_DRAFT.md) - 簡報草稿
- [DEMO_SCRIPT.md](DEMO_SCRIPT.md) - Demo 演示腳本

---
---

# 📋 Cloud-native Milestone - Progress Checklist (English)

> Based on `functions.txt` requirements document
> 
> Last Updated: 2026-01-21

---

## 🎯 Overall Assessment

| Evaluation Item | Status | Description |
|-----------------|--------|-------------|
| **Wow Factors Count** | ✅ 3+ | Dynamic Feed + AI Recommendation + Ad Service |
| **Microservice Architecture** | ✅ | Frontend + Backend + Ad-Service + MySQL |
| **Separate Microservice Wow** | ✅ | Ad-Service deployed independently on Port 3002 |
| **Kubernetes Deployment** | ✅ | Complete k8s/ and k8s-gke/ configurations |
| **IaC Automation** | ✅ | Terraform + kubectl apply |
| **Load Testing Scripts** | ✅ | locust/locustfile.py |

---

## 📦 SaaS B2B Plan Architecture

### Membership Tier System
| Item | Status | Implementation |
|------|--------|----------------|
| Free Plan | ✅ | `membership_tier = 'Free'` (default) |
| Standard Plan | ✅ | `membership_tier = 'Premium'` |
| Enterprise Plan | ⬜ | Not implemented |
| Tier Badge UI | ✅ | `ProfileCard.vue` displays tier badge |
| Admin User Upgrade | ✅ | `AdminDashboard.vue` |
| Premium Exclusive Features | ✅ | Private trips, hide ads, Gemini 3 AI |

---

## ✈️ Itinerary Management

> Milestone 1 hygiene factors

| Item | Status | Implementation |
|------|--------|----------------|
| Create Itinerary | ✅ | `POST /api/itineraries` |
| Edit Itinerary | ✅ | `PUT /api/itineraries/:id` |
| Delete Itinerary | ✅ | `DELETE /api/itineraries/:id` |
| View Itinerary Details | ✅ | `GET /api/itineraries/detail/:id` |
| Itinerary List | ✅ | `GET /api/itineraries/by-email/:email` |
| Destination | ✅ | `destination` field |
| Date Range | ✅ | `start_date`, `end_date` |
| Short Description | ✅ | `short_description` (80 char limit) |
| Detail Description | ✅ | `detail_description` |
| Private Itinerary | ✅ | `is_private` field (Premium only) |
| Clone Itinerary | ✅ | `ItineraryManager.vue` → `cloneTrip()` |
| Departure Airport | ⬜ | Not implemented (optional) |
| Flight Number | ⬜ | Not implemented (optional) |

---

## 👥 Social Interaction

> Implemented as separate service → **Firebase Firestore**

| Item | Status | Implementation |
|------|--------|----------------|
| Like Feature | ✅ | `POST /api/itineraries/:id/like/toggle` |
| Like Count | ✅ | `GET /api/itineraries/:id/like/count` |
| Like List | ✅ | `GET /api/itineraries/:id/like/list` |
| Comment Feature | ✅ | `POST /api/itineraries/:id/comments` |
| Comment List | ✅ | `GET /api/itineraries/:id/comments` |
| Delete Own Comment | ✅ | `DELETE /api/itineraries/:id/comments/:commentId` |
| View Other User Profiles | ✅ | `?profile=email@example.com` URL parameter |
| Guest Mode Browsing | ✅ | View public content & feed without login |
| Share Link | ✅ | `ItineraryManager.vue` → `shareTrip()` |

### Wow Factors

| Item | Status | Implementation |
|------|--------|----------------|
| **🌟 Personalized Live Feed** | ✅ | `DynamicFeed.vue` - Shows all public itineraries |
| Personalized Newsletter | ⬜ | Not implemented (optional) |
| **🌟 AI Recommendation Engine** | ✅ | `Gemini 3 / Gemma 3` auto-generates travel suggestions |

---

## 🏝️ Destination Management - Wow Factors

> Separate Microservice: **Ad-Service** (Port 3002)

| Item | Status | Implementation |
|------|--------|----------------|
| **🌟 Buy Ad Placements** | ✅ | `POST /api/ads` |
| **🌟 Special Offers Management** | ✅ | `discount_code` field |
| **🌟 Attraction Discount Marketing** | ✅ | `external_url` external link redirect |
| Ad CRUD | ✅ | Complete Create/Read/Update/Delete |
| Filter Ads by Destination | ✅ | `GET /api/ads?destination=Kyoto` |
| Ad Images | ✅ | `image_url` field |
| Merchant Dashboard UI | ✅ | `MerchantDashboard.vue` |
| Ad Carousel Display | ✅ | `AdBanner.vue` in itinerary details & feed |
| Default Seed Data | ✅ | 10 sample ads (Kyoto, Tokyo, Paris, Kenting, Taitung, etc.) |
| External Link Redirect | ✅ | `target="_blank"` opens in new window |

---

## 🌍 Travel Information - Wow Factors (Optional)

| Item | Status | Description |
|------|--------|-------------|
| Flight Schedule Change Parsing | ⬜ | Not implemented (requires Flight API) |
| Official Travel Warnings | ⬜ | Not implemented |
| **🌟 Weather Information Processing** | ⚠️ Partial | AI suggestions include seasonal/weather tips |

---

## 🔄 Async Workflows

> Each Wow factor uses async workflows for efficient data processing

### AI Recommendation Engine Async Processing
| Item | Status | Implementation |
|------|--------|----------------|
| Soft Timeout Mechanism | ✅ | `server.js:500` - 4 sec foreground timeout |
| Background Fallback | ✅ | `server.js:525-546` - Background processing after timeout |
| Firestore State Storage | ✅ | `aiSuggestions/{id}` collection |
| Frontend Polling | ✅ | `ItineraryManager.vue:47-62` - Poll every 2 sec |
| Max Tries Control | ✅ | Max 8 polling attempts (16 sec) |
| User Toggle Control | ✅ | `enable_ai: false` to disable AI |

### Social Features Async Processing
| Item | Status | Implementation |
|------|--------|----------------|
| Optimistic UI Update | ✅ | Immediate UI update for likes/comments |
| Parallel Loading | ✅ | `loadLikesForVisibleTrips()` parallel load |
| Background Cleanup | ✅ | Background Firestore cleanup on delete |

### Ad Service Async Processing
| Item | Status | Implementation |
|------|--------|----------------|
| Fallback Strategy | ✅ | Random ads when no destination match |
| Watch Reactive | ✅ | Auto-reload on destination change |
| Seed Data Init | ✅ | Async init on service startup |

---

## ⚙️ Technical Requirements

### Microservice Architecture & 12-Factor
| Item | Status | Description |
|------|--------|-------------|
| Microservice Architecture | ✅ | 4 services: Frontend, Backend, Ad-Service, MySQL |
| Codebase | ✅ | Git version control |
| Dependencies | ✅ | Explicitly declared in package.json |
| Config | ✅ | Environment variables (.env, K8s Secrets) |
| Backing Services | ✅ | MySQL, Firebase, GCS, Gemini |
| Build/Release/Run Separation | ✅ | Docker build → K8s apply → rollout |
| Stateless Processes | ✅ | Pods are stateless, data in MySQL/Firestore |
| Port Binding | ✅ | 3000, 3002, 80 |
| Concurrency | ✅ | K8s replicas adjustable |
| Fast Startup/Graceful Shutdown | ✅ | Container starts in seconds |
| Dev/Prod Parity | ✅ | Docker ensures environment consistency |
| Logs | ✅ | JSON structured logs to stdout |
| Admin Processes | ✅ | AdminDashboard management interface |

### Kubernetes Deployment
| Item | Status | Description |
|------|--------|-------------|
| Core Components on K8s | ✅ | All 4 services deployed to K8s |
| Local K8s (OrbStack) | ✅ | `k8s/` directory |
| GKE Deployment | ✅ | `k8s-gke/` directory |
| PersistentVolume | ✅ | MySQL data persistence |
| ConfigMap | ✅ | mysql-init-scripts |
| Secrets | ✅ | backend-secrets (API Keys) |
| LoadBalancer Service | ✅ | Frontend external service |
| HPA Autoscaling | ✅ | Configured (needs validation) |

### IaC Automation
| Item | Status | Description |
|------|--------|-------------|
| Deployment Automation | ✅ | `kubectl apply -f k8s/` |
| Dockerfile | ✅ | All three services have Dockerfile |
| Deployment Scripts | ✅ | `local_deploy.sh`, `local_deploy.ps1` |
| Terraform GKE | ✅ | `terraform/main.tf` (GKE Cluster + Node Pool) |
| Redeploy Workflow | ✅ | `.agent/workflows/redeploy_k8s.md` |

### Performance Testing
| Item | Status | Description |
|------|--------|-------------|
| Performance Test Scripts | ✅ | `locust/locustfile.py` (Locust) |
| Test Coverage | ✅ | Feed, Detail, Likes, Comments, Health |
| Performance Test Reports | ⚠️ Partial | Need to run and generate report |
| Test Data Sets | ✅ | `dummy_data.sql` + Ad-Service seed data |

---

## 📊 Completion Summary

### Functional Area Completion

| Area | Completion | Notes |
|------|------------|-------|
| Itinerary Management | 95% | Complete CRUD + Clone + Private trips |
| Social Interaction | 95% | Complete Likes/Comments/Share, missing newsletter |
| Destination Management | **100%** | ✅ Complete Wow Factor + External links |
| AI Recommendations | **100%** | ✅ Dual model support (Gemini 3 / Gemma 3) |
| Technical Requirements | 95% | Complete test scripts, need to generate reports |

### Wow Factors Checklist

| Wow Factor | Status | Microservice | Category |
|------------|--------|--------------|----------|
| ✅ Personalized Live Feed | Complete | Frontend | Social Interaction |
| ✅ AI Recommendation Engine | Complete | Backend (Gemini) | Social Interaction |
| ✅ Destination Ad Placements | Complete | **Ad-Service** | Destination Management |
| ✅ Special Offers/Discounts | Complete | **Ad-Service** | Destination Management |
| ✅ External Link Marketing | Complete | **Ad-Service** | Destination Management |
| ⬜ Personalized Newsletter | Not Complete | - | Social (Optional) |
| ⬜ Flight Schedule Changes | Not Complete | - | Travel Info (Optional) |
| ⬜ Travel Warnings | Not Complete | - | Travel Info (Optional) |

### Rating

```
🏆 Rating: Very Good

Justification:
✅ Implemented 3+ Wow factors (Dynamic Feed + AI + Full Destination Management)
✅ Wow factors distributed across different microservices (Backend AI + Ad-Service)
✅ Complete Kubernetes deployment (Local + GKE)
✅ IaC automation (Terraform + kubectl)
✅ Load testing scripts (Locust)
✅ Complete Merchant Dashboard (MerchantDashboard)
✅ External link redirect functionality
```

---

## 📝 Suggested Improvements

### High Priority (Completed ✅)
1. ~~**Performance Test Scripts**~~ - ✅ Locust implemented
2. ~~**External Link Feature**~~ - ✅ Ad-Service external_url implemented

### Medium Priority (Optional)
3. **Performance Test Reports** - Run Locust and export report files
4. **Flight Info Fields** - Add `departure_airport`, `flight_number` to itineraries table
5. **Async Workflow Control** - Use Redis Queue or Cloud Tasks

### Low Priority (Advanced Features)
6. **Personalized Newsletter** - Periodic email sending (SendGrid / Mailgun)
7. **Travel Warnings** - Integrate external API (Travel Advisory)
8. **Flight Schedule Changes** - Integrate FlightAware API
9. **Enterprise Plan** - Highly customizable features

---

## 🔗 Related Documents

- [README.md](README.md) - Main documentation
- [K8S_DEPLOY_GUIDE.md](K8S_DEPLOY_GUIDE.md) - GKE deployment guide
- [K8S_DEPLOY_GUIDE_LOCAL.md](K8S_DEPLOY_GUIDE_LOCAL.md) - Local K8s deployment guide
- [TERRAFORM_DEPLOY_GUIDE.md](TERRAFORM_DEPLOY_GUIDE.md) - Terraform deployment guide
- [PRESENTATION_DRAFT.md](PRESENTATION_DRAFT.md) - Presentation draft
- [DEMO_SCRIPT.md](DEMO_SCRIPT.md) - Demo script
