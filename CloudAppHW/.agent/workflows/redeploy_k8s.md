---
description: 當修改了程式碼或 K8s 設定後，重新建置 Docker Image 並更新 Kubernetes 部署。
---

1. 重新建置後端 Image (Rebuild Backend)
// turbo
cd /Users/iambjlu/IdeaProjects/web/CloudAppHW/CloudAppHW
docker build -t backend-api:latest ./backend-api

2. 重新建置前端 Image (Rebuild Frontend)
// turbo
cd /Users/iambjlu/IdeaProjects/web/CloudAppHW/CloudAppHW
docker build -t frontend-vue:latest ./frontend-vue

3. 套用 K8s 設定變更 (Apply K8s Configs)
// turbo
cd /Users/iambjlu/IdeaProjects/web/CloudAppHW/CloudAppHW/k8s
kubectl apply -f .

4. 重啟 Deployment 以讀取新 Image (Restart Deployments)
// turbo
kubectl rollout restart deployment backend frontend

5. 記得commit