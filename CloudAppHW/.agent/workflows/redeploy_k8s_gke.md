---
description: 當修改了程式碼或 K8s 設定後，重新建置 Docker Image 並更新 Kubernetes 部署。
---

1. 重新建置後端 Image (Rebuild Backend)
// turbo
cd /Users/iambjlu/IdeaProjects/web/CloudAppHW/CloudAppHW
docker build --platform linux/amd64 -t gcr.io/htwg-cloudapp-hw/backend-api:latest ./backend-api
docker push gcr.io/htwg-cloudapp-hw/backend-api:latest

2. 重新建置 Ad Service Image (Rebuild Ad Service)
// turbo
cd /Users/iambjlu/IdeaProjects/web/CloudAppHW/CloudAppHW
docker build --platform linux/amd64 -t gcr.io/htwg-cloudapp-hw/ad-service:latest ./ad-service
docker push gcr.io/htwg-cloudapp-hw/ad-service:latest

3. 重新建置前端 Image (Rebuild Frontend)
// turbo
cd /Users/iambjlu/IdeaProjects/web/CloudAppHW/CloudAppHW
docker build --platform linux/amd64 -t gcr.io/htwg-cloudapp-hw/frontend-vue:latest ./frontend-vue
docker push gcr.io/htwg-cloudapp-hw/frontend-vue:latest

4. 套用 K8s 設定變更 (Apply K8s Configs)
// turbo
cd /Users/iambjlu/IdeaProjects/web/CloudAppHW/CloudAppHW/k8s-gke
kubectl apply -f .

5. 重啟 Deployment 以讀取新 Image (Restart Deployments)
// turbo
kubectl rollout restart deployment backend ad-service frontend mysql

6. 檢查 Pod 狀態
kubectl get pods