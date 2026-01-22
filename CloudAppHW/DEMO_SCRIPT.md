# DragonFlyX - Checkpoint / Demo Script (中文/English)

## 1. 開場介紹 (Intro)
**Time**: 0:00 - 0:30

- **中文**: 大家好，我們是 **Team Kenting**。這是我們的作品 **DragonFlyX**，一個結合生成式 AI 的智慧旅遊行程規劃平台。我們的目標是讓用戶只要輸入簡單的想法，就能透過 Google Gemini 獲得完整的旅遊建議，同時整合了廣告商的精準投放功能。
- **English**: Hello everyone, we are **Team Kenting**. This is **DragonFlyX**, a smart travel itinerary planner powered by Generative AI. Our goal is to let users get complete travel suggestions via Google Gemini by simply inputting their ideas, while also integrating precision advertising capabilities.

---

## 2. 架構總覽 (Architecture Overview)
**Time**: 0:30 - 1:00
*(Show System Architecture Diagram or Explain briefly)*

- **中文**: 我們的系統採用微服務架構：
  - **Frontend**: 使用 Vue 3 打造響應式介面。
  - **Backend**: 分為 **Core API Service** (處理行程與 AI) 與 **Ad Service** (處理廣告)。
  - **Database**: 結合 **MySQL** (儲存核心資料) 與 **Firestore** (儲存 AI 建議與即時互動)。
  - **Infrastructure**: 全部部署在 Google Kubernetes Engine (GKE) 上。
- **English**: Our system uses a microservices architecture:
  - **Frontend**: Built with Vue 3 for a responsive UI.
  - **Backend**: Split into **Core API Service** (Itinerary & AI) and **Ad Service** (Ads).
  - **Database**: Combines **MySQL** (Core data) and **Firestore** (AI & Real-time data).
  - **Infrastructure**: Fully deployed on GKE.

---

## 3. 功能演示 (Feature Demo)

### Scenario A: 一般用戶體驗 (User Journey)
**Time**: 1:00 - 2:30

1.  **註冊/登入 (Register/Login)**:
    -   *Action*: 在首頁輸入 Email 註冊一個新帳號。
    -   *Explanation*: "我們使用 Firebase Auth 進行安全的身份驗證。"
2.  **建立行程 (Create Trip with AI)**:
    -   *Action*: 輸入 "Kyoto", "5 days", Description: "Relaxing trip with tea ceremony".
    -   *Action*: 選擇 **Standard Model (Gemma 3)** 或 **Premium Model (Gemini 3)** (如果有點數)。
    -   *Result*: 按下 Create，系統顯示 Loading，隨後跳出 AI 生成的建議 (Must-see, Food etc.)。
    -   *Explanation*: "後端會即時呼叫 Gemini API 生成客製化建議。如果回應較慢，系統會自動轉為背景處理。"
3.  **查看詳情與廣告 (View Details & Ads)**:
    -   *Action*: 點擊剛建立的京都行程。
    -   *Observation*: 捲動下方，看到 **"Sponsored: Traditional Kimono Rental"** 的廣告卡片。
    -   *Explanation*: "這就是我們的微服務整合。Ad Service 根據目的地的關鍵字 'Kyoto'，自動推播相關的廣告給用戶。"

### Scenario B: 管理員與廣告操作 (Admin & Ad Operations)
**Time**: 2:30 - 4:00

1.  **管理員入口 (Admin Portal)**:
    -   *Action*: 登出，改登入 **Admin 帳號** (第一個註冊的帳號)。
    -   *Action*: 點擊右上角 **"Admin Portal"**。
    -   *Result*: 看到用戶列表，可以將剛才的測試帳號升級為 **Premium**。
2.  **廣告管理 (B2B Feature)**:
    -   *Action*: 在 Admin Portal 點擊底部的 **"Merchant Entrance"** (這是專屬管理員的隱藏入口)。
    -   *Result*: 進入 **Merchant Dashboard**。
    -   *Action*: 新增一個廣告：
        -   Destination: "Taipei"
        -   Title: "Taipei 101 Fast Pass"
        -   Code: "101GO"
    -   *Explanation*: "這是廣告商提供資料後，由管理員進行上架的後台。我們將此功能限制為僅管理員可操作，確保平台內容品質。"

---

## 4. 結尾與問答 (Conclusion & Q&A)
**Time**: 4:00 - End

- **中文**: DragonFlyX 展示了如何利用 Cloud Native 技術整合 AI 與傳統 Web 應用，實現可擴展且智慧的服務。謝謝大家！
- **English**: DragonFlyX demonstrates how to integrate AI with traditional Web apps using Cloud Native technologies to achieve scalable and smart services. Thank you!
