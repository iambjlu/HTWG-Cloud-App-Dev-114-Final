# 🎯 DragonFlyX 簡報草稿 / Presentation Draft

> 最後更新 / Last Updated: 2026-01-21

---

## 📑 簡報大綱 / Outline

1. **專案概述 / Overview** (2 分鐘)
2. **功能展示 / Feature Demo** (5 分鐘)
3. **架構說明 / Architecture** (3 分鐘)
4. **技術亮點 / Technical Highlights** (3 分鐘)
5. **Demo 演示 / Live Demo** (5 分鐘)
6. **Q&A** (2 分鐘)

---

# Slide 1: 標題頁 / Title

## 🐲 DragonFlyX
### 雲端社交旅遊規劃平台
### Cloud-Native Social Travel Planning Platform

**Team:** Kenting 🏖️  
**Member:** Po-Chun Lu  
**Course:** Cloud Application Development  

---

# Slide 2: 專案概述 / Project Overview

## 問題與解決方案 / Problem & Solution

| 問題 Problem | 解決方案 Solution |
|--------------|-------------------|
| 傳統旅遊規劃分散且難分享 | 雲端集中管理，一鍵分享 |
| 缺乏個人化建議 | AI 自動生成旅遊建議 |
| 商家難以接觸旅客 | B2B 廣告投放平台 |
| 不同用戶需求差異 | 會員等級區分 (Free/Premium) |

---

# Slide 3: 核心功能 / Core Features

## ✅ 已實作功能

| 功能 | Feature | 說明 |
|------|---------|------|
| 🗺️ 行程管理 | CRUD | 建立/編輯/刪除/檢視 |
| 👥 社交互動 | Social | 按讚/留言/分享/複製行程 |
| 🤖 AI 建議 | Gemini AI | 自動生成旅遊建議 |
| 📢 廣告系統 | Ad Service | 獨立微服務 + 外部連結 |
| 👑 會員等級 | Membership | Free / Premium |
| 🔒 私人行程 | Private | Premium 專屬功能 |
| 📸 頭像上傳 | Avatar | GCS 儲存 + 壓縮處理 |
| 🛡️ 管理員 | Admin | 用戶管理 + 等級調整 |
| 🏪 商家後台 | Merchant | 廣告 CRUD 管理 |

---

# Slide 4: Wow 因素 / Wow Factors

## 🌟 三大亮點

### 1. 個人化動態牆 (Dynamic Feed)
- 即時顯示所有公開行程
- 支援訪客瀏覽 (無需登入)
- 一鍵複製行程功能
- 點擊卡片跳轉行程詳情

### 2. AI 推薦引擎 (AI Recommendations)
- **Premium (Gemini 3)**: 高品質 AI 模型
- **Standard (Gemma 3)**: 標準 AI 模型
- 自動生成景點、美食、季節建議
- 可選擇開/關 AI 功能
- 背景非同步處理機制

### 3. 目的地管理系統 (Destination Management)
- **獨立微服務架構** (Ad-Service, Port 3002)
- 商家後台管理廣告 (MerchantDashboard)
- 依目的地自動推薦相關廣告
- 支援外部連結跳轉 (external_url)
- 動態輪播展示 (AdBanner)

---

# Slide 5: 系統架構 / Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  Kubernetes Cluster (GKE)                    │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Frontend   │  │   Backend    │  │  Ad-Service  │       │
│  │   Vue.js     │  │  Express.js  │  │  Express.js  │       │
│  │   Nginx:80   │  │   Port:3000  │  │  Port:3002   │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                 │                 │                │
│         └─────────────────┼─────────────────┘                │
│                           │                                  │
│                    ┌──────▼──────┐                          │
│                    │    MySQL    │                          │
│                    │  Port:3306  │                          │
│                    └─────────────┘                          │
└──────────────────────────────────────────────────────────────┘
               │            │            │            │
          ┌────▼────┐  ┌────▼────┐  ┌────▼────┐  ┌────▼────┐
          │Firebase │  │   GCS   │  │ Gemini  │  │Firestore│
          │  Auth   │  │ Storage │  │   AI    │  │ (Social)│
          └─────────┘  └─────────┘  └─────────┘  └─────────┘
```

---

# Slide 6: 技術棧 / Tech Stack

| 層級 | 技術 |
|------|------|
| **Frontend** | Vue.js 3 + Vite + Tailwind CSS |
| **Backend** | Node.js + Express.js |
| **Database** | MySQL + Firebase Firestore |
| **AI** | Google Gemini API (Gemini 3 / Gemma 3) |
| **Storage** | Google Cloud Storage (GCS) |
| **Auth** | Firebase Authentication |
| **Container** | Docker |
| **Orchestration** | Kubernetes (Local + GKE) |
| **IaC** | Terraform + kubectl |
| **Testing** | Locust (負載測試) |

---

# Slide 7: 12-Factor 合規 / 12-Factor Compliance

| Factor | 實作方式 |
|--------|----------|
| ✅ Codebase | Git 版控 |
| ✅ Dependencies | package.json 明確宣告 |
| ✅ Config | 環境變數 + K8s Secrets |
| ✅ Backing Services | MySQL, Firebase, GCS, Gemini |
| ✅ Build/Release/Run | Docker build → K8s apply → rollout |
| ✅ Processes | Stateless Pods |
| ✅ Port Binding | 3000, 3002, 80 |
| ✅ Concurrency | K8s replicas 可調整 |
| ✅ Disposability | Fast startup (容器秒級啟動) |
| ✅ Dev/Prod Parity | Docker 確保環境一致 |
| ✅ Logs | JSON 結構化日誌輸出至 stdout |
| ✅ Admin | AdminDashboard 管理介面 |

---

# Slide 8: 非同步工作流程 / Async Workflows

> 每個 Wow 因素都採用非同步工作流程，提升資料處理效率
> Each Wow factor uses async workflows for efficient data processing

## 🔄 AI 推薦引擎 (AI Recommendation Engine)

### 工作流程 / Workflow:
```
┌─────────────┐    ┌───────────────┐    ┌──────────────┐
│  使用者建立  │───▶│  Soft Timeout  │───▶│ 前景成功返回  │
│   行程請求   │    │   (4 秒)       │    │   AI 建議    │
└─────────────┘    └───────┬───────┘    └──────────────┘
                          │ 超時
                          ▼
              ┌───────────────────────┐
              │   背景非同步任務      │
              │   (Background Task)   │
              └───────────┬───────────┘
                          ▼
              ┌───────────────────────┐
              │  寫入 Firestore       │
              │  aiSuggestions/{id}   │
              └───────────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │  前端 Polling 取得    │
              │  (每 2 秒輪詢)        │
              └───────────────────────┘
```

### 控制機制 / Control Mechanisms:
| 機制 | 說明 | 位置 |
|------|------|------|
| **Soft Timeout** | 前景請求 4 秒超時，避免阻塞 | `server.js:500` |
| **Background Fallback** | 超時後轉為背景任務繼續處理 | `server.js:525-546` |
| **Polling with Max Tries** | 前端最多輪詢 8 次 (16 秒) | `ItineraryManager.vue:47-62` |
| **Status Tracking** | 狀態追蹤: idle/queued/ok/error | Firestore `aiSuggestions` |
| **User Control** | 用戶可選擇關閉 AI (`enable_ai: false`) | `AuthAndCreate.vue` |

---

## 🔄 社交功能非同步處理 / Social Async Processing

### Likes & Comments (Firestore):
```
┌─────────────┐    ┌───────────────┐    ┌──────────────┐
│  使用者點讚  │───▶│  Firestore    │───▶│  即時更新 UI  │
│   /留言     │    │  非同步寫入    │    │  (Optimistic) │
└─────────────┘    └───────────────┘    └──────────────┘
```

### 控制機制:
| 機制 | 說明 |
|------|------|
| **Optimistic UI Update** | 立即更新 UI，不等待後端確認 |
| **Parallel Loading** | `loadLikesForVisibleTrips()` 平行載入 |
| **Background Cleanup** | 刪除行程時，背景清理 Firestore 資料 |

---

## 🔄 廣告服務非同步 / Ad Service Async

### 控制機制:
| 機制 | 說明 |
|------|------|
| **Fallback Strategy** | 無目的地廣告時，隨機推薦 2 則 |
| **Watch Reactive** | 目的地變更時自動重新載入 |
| **Seed Data Init** | 服務啟動時非同步初始化種子資料 |

---

# Slide 9: Vue Components 元件說明

| 元件 | 功能說明 |
|------|----------|
| **App.vue** | 主應用，狀態管理，路由控制 |
| **AuthAndCreate.vue** | 登入/註冊/建立行程表單 |
| **ItineraryManager.vue** | 行程列表 + 詳情 + 編輯 + 社交互動 |
| **ProfileCard.vue** | 用戶卡片 + 頭像上傳 (GCS) |
| **DynamicFeed.vue** | 動態牆 (Wow Factor #1) |
| **AdBanner.vue** | 廣告輪播 (Wow Factor #3) |
| **AdminDashboard.vue** | 管理員用戶管理 |
| **MerchantDashboard.vue** | 商家廣告 CRUD (Wow Factor #3) |
| **GlobalModal.vue** | 全域彈窗元件 |

---

# Slide 10: Demo 流程 / Demo Plan


## 🎬 演示順序

### Step 1: 登入/註冊 (1 分鐘)
- 開啟首頁，展示未登入狀態
- 展示動態牆 (訪客也能看)
- 註冊新帳號
- 顯示 Free 會員等級

### Step 2: 建立行程 (2 分鐘)
- 填寫行程資料 (目的地: Kyoto)
- 選擇 AI 建議模式 (Standard: Gemma 3)
- 建立後展示 AI 生成的建議
- 展示行程詳情頁

### Step 3: 社交功能 (1 分鐘)
- 瀏覽動態牆
- 點讚/留言其他行程
- 複製行程功能
- 分享連結

### Step 4: 廣告展示 (30 秒)
- 查看行程詳情頁底部的廣告
- 展示依目的地篩選的廣告
- 點擊廣告跳轉外部連結

### Step 5: 商家後台 (1 分鐘)
- 以管理員身份登入
- 進入 Admin Portal
- 升級用戶為 Premium
- 進入 Merchant Portal
- 新增一則廣告

### Step 6: 進階功能 (可選)
- 展示 Private 行程 (Premium)
- 上傳頭像功能
- Premium 用戶隱藏廣告

---

# Slide 10: 完成度總結 / Completion Summary

## 功能區域完成度

| 區域 | 完成度 | 說明 |
|------|--------|------|
| 行程管理 | 90% | 缺少航班資訊欄位 |
| 社交互動 | 95% | 缺少電子報功能 |
| 目的地管理 | **100%** | ✅ 完整 Wow 因素 |
| AI 推薦 | **100%** | ✅ Gemini 3 / Gemma 3 |
| 技術需求 | 90% | 完整負載測試腳本 |

## Wow 因素達成

| Wow 因素 | 狀態 | 微服務 |
|----------|------|--------|
| ✅ 個人化即時動態牆 | 完成 | Frontend (DynamicFeed.vue) |
| ✅ AI 推薦引擎 | 完成 | Backend (Gemini API) |
| ✅ 目的地廣告版位 | 完成 | **Ad-Service** |
| ✅ 特別優惠/折扣 | 完成 | **Ad-Service** |

### 🏆 評級: Very Good (非常好)

- ✅ 實作 2+ 個 Wow 因素
- ✅ Wow 因素分布在不同微服務 (Backend AI + Ad-Service)
- ✅ 完整 Kubernetes 部署 (Local + GKE)
- ✅ IaC 自動化 (Terraform)
- ✅ 負載測試腳本 (Locust)

---

# Slide 11: 結語 / Conclusion

## 謝謝！Questions?

### 專案亮點回顧 / Project Highlights

1. **雲端原生架構** - 微服務 + Kubernetes + IaC
2. **AI 驅動體驗** - Gemini API 自動生成建議
3. **B2B 商業模式** - 廣告投放平台
4. **完整社交功能** - 按讚/留言/分享/複製

### 相關資源 / Resources

- 📂 GitHub Repository
- 📄 README.md - 完整文件
- 📊 PROGRESS_CHECKLIST.md - 功能清單
- 🔧 K8S_DEPLOY_GUIDE.md - GKE 部署指南
- 🏗️ TERRAFORM_DEPLOY_GUIDE.md - Terraform 指南

---

## 🎯 Demo 起始點 / Demo Start Points

### 情境 A: 完整流程 (推薦)
1. 開啟 GKE External IP 首頁
2. 從動態牆開始，展示訪客模式
3. 註冊帳號，建立行程

### 情境 B: 快速展示
1. 預先登入 Premium 帳號
2. 直接展示建立行程 + AI 建議

### 情境 C: 商家功能
1. 使用管理員帳號登入
2. 展示 Admin Portal → Merchant Portal
3. 新增廣告後回到行程頁查看

### 情境 D: 技術展示
1. 開啟 GKE Console 展示 Pod 狀態
2. 執行 Locust 負載測試
3. 展示 HPA 自動擴展

---

## 📝 演講稿重點 / Speaking Notes

### 開場 (30 秒)
> "大家好，我是團隊 Kenting。今天要介紹的是 DragonFlyX，一個結合 AI 的雲端旅遊規劃平台。"

### 架構說明 (1 分鐘)
> "我們採用微服務架構。Frontend 用 Vue.js，Backend 用 Express.js 處理核心邏輯，Ad-Service 是獨立的廣告微服務，這也是我們的 Wow Factor 之一。所有服務都部署在 GKE 上。"

### AI 功能 (1 分鐘)
> "當用戶建立行程時，可以選擇 AI 建議模式。Premium 用戶使用 Gemini 3，Free 用戶使用 Gemma 3。AI 會自動生成景點推薦、美食建議等。"

### 廣告系統 (1 分鐘)
> "我們的廣告系統是獨立的微服務。商家可以透過 Merchant Portal 管理廣告，系統會根據行程目的地自動推薦相關廣告給用戶。"

### 結尾 (30 秒)
> "DragonFlyX 展示了如何用雲端原生技術整合 AI 與社交功能，實現可擴展的 SaaS 解決方案。謝謝大家！"

---
*簡報結束*

### Control Mechanisms
| Mechanism | Description |
|---------|-------------|
| **Optimistic UI Update** | UI updates immediately |
| **Parallel Loading** | `loadLikesForVisibleTrips()` |
| **Background Cleanup** | Async Firestore cleanup on trip deletion |

---

## 🔄 Ad Service Async Handling

### Control Mechanisms
| Mechanism | Description |
|---------|-------------|
| **Fallback Strategy** | Random ads when destination has none |
| **Watch Reactive** | Reload ads when destination changes |
| **Seed Data Init** | Async seed data on service startup |

---

# Slide 9: Vue Components Overview

| Component | Description |
|---------|-------------|
| **App.vue** | App root, state & routing |
| **AuthAndCreate.vue** | Auth + trip creation |
| **ItineraryManager.vue** | Trip list, detail, edit, social |
| **ProfileCard.vue** | User profile + avatar upload |
| **DynamicFeed.vue** | Social feed (Wow #1) |
| **AdBanner.vue** | Rotating ads (Wow #3) |
| **AdminDashboard.vue** | Admin user management |
| **MerchantDashboard.vue** | Merchant ad CRUD |
| **GlobalModal.vue** | Global modal component |

---

# Slide 10: Demo Plan

## 🎬 Demo Flow

### Step 1: Login / Register (1 min)
- Open homepage as guest
- Show dynamic feed
- Register a new account
- Display Free membership

### Step 2: Create Trip (2 min)
- Destination: Kyoto
- Select AI mode (Standard: Gemma 3)
- Show AI-generated suggestions
- Open trip detail page

### Step 3: Social Features (1 min)
- Browse feed
- Like / comment trips
- Clone trip
- Share link

### Step 4: Ads Display (30 sec)
- Show destination-based ads
- Click external ad link

### Step 5: Merchant Portal (1 min)
- Login as admin
- Upgrade user to Premium
- Create a new ad

### Step 6: Advanced Features (Optional)
- Private trips
- Avatar upload
- Ad-free Premium experience

---

# Slide 11: Completion Summary

## Feature Completion

| Area | Completion | Notes |
|----|-----------|------|
| Itinerary Management | 90% | Missing flight info |
| Social Interaction | 95% | Newsletter pending |
| Destination Management | **100%** | Full Wow Factor |
| AI Recommendation | **100%** | Gemini 3 / Gemma 3 |
| Technical Requirements | 90% | Load test scripts ready |

## Wow Factors Achieved

| Wow Factor | Status | Microservice |
|----------|--------|--------------|
| Dynamic Social Feed | ✅ | Frontend |
| AI Recommendation Engine | ✅ | Backend |
| Destination Ads | ✅ | Ad-Service |
| Special Offers | ✅ | Ad-Service |

### 🏆 Rating: Very Good

---

# Slide 12: Conclusion

## Thank You! Questions?

### Project Highlights
1. Cloud-native architecture
2. AI-powered experience
3. B2B advertising model
4. Full social interaction features

### Resources
- GitHub Repository
- README.md
- PROGRESS_CHECKLIST.md
- K8S_DEPLOY_GUIDE.md
- TERRAFORM_DEPLOY_GUIDE.md

---

*End of Presentation Draft*
