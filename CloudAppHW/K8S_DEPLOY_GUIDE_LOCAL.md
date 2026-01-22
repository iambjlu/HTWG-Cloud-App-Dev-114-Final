# 本地 Kubernetes 部署指南 / Local Kubernetes Deployment Guide

本指南說明如何將 DragonFlyX 應用程式部署到本地 Kubernetes 集群。
This guide explains how to deploy the DragonFlyX application to a local Kubernetes cluster.

## 前置需求 / Prerequisites

- Docker Desktop (with Kubernetes enabled) or minikube
- kubectl configured for local cluster
- Docker images built locally

## 步驟 / Steps

### 1. 建置 Docker Images / Build Docker Images

```bash
cd /Users/iambjlu/IdeaProjects/web/CloudAppHW/CloudAppHW

# 建置後端 / Build Backend
docker build -t backend-api:latest ./backend-api

# 建置廣告服務 / Build Ad Service
docker build -t ad-service:latest ./ad-service

# 建置前端 / Build Frontend
docker build -t frontend-vue:latest ./frontend-vue
```

### 2. 套用 Kubernetes 設定 / Apply Kubernetes Configs

```bash
cd k8s
kubectl apply -f .
```

### 3. 檢查部署狀態 / Check Deployment Status

```bash
kubectl get pods
kubectl get services
```

### 4. 取得服務 URL / Get Service URLs

```bash
# 前端 URL (using NodePort)
kubectl get service frontend -o jsonpath='{.spec.ports[0].nodePort}'
# 存取: http://localhost:<nodePort>

# 後端 URL
kubectl get service backend -o jsonpath='{.spec.ports[0].nodePort}'
```

### 5. 重新部署 / Redeploy

若需要重新部署（程式碼變更後）：

```bash
# 重建 Images
docker build -t backend-api:latest ./backend-api
docker build -t ad-service:latest ./ad-service
docker build -t frontend-vue:latest ./frontend-vue

# 重啟 Deployments
kubectl rollout restart deployment backend ad-service frontend mysql
```

## 疑難排解 / Troubleshooting

### 查看 Pod 日誌 / View Pod Logs
```bash
kubectl logs -f deployment/backend
kubectl logs -f deployment/frontend
```

### 進入 Pod Shell / Access Pod Shell
```bash
kubectl exec -it deployment/backend -- /bin/sh
```

### 檢查 ConfigMaps 和 Secrets
```bash
kubectl get configmaps
kubectl get secrets
kubectl describe configmap backend-config
```
