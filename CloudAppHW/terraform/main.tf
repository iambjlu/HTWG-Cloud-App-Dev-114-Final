# =============================================================================
# Terraform Configuration for GKE Deployment
# 雲端應用程式 Infrastructure as Code (IaC) 設定
# =============================================================================

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# -----------------------------------------------------------------------------
# Provider Configuration
# -----------------------------------------------------------------------------

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials_file)
}

# GKE Cluster 驗證配置
data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
  name     = google_container_cluster.primary.name
  location = var.region
  
  depends_on = [google_container_cluster.primary]
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

# -----------------------------------------------------------------------------
# Enable Required Google Cloud APIs
# 啟用所需的 GCP API
# -----------------------------------------------------------------------------

resource "google_project_service" "required_apis" {
  for_each = toset([
    "container.googleapis.com",           # GKE API
    "containerregistry.googleapis.com",   # GCR API
    "compute.googleapis.com",             # Compute Engine API
    "iam.googleapis.com",                 # IAM API
  ])
  
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# -----------------------------------------------------------------------------
# GKE Cluster
# -----------------------------------------------------------------------------

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  
  # 刪除預設 node pool，使用自訂的
  remove_default_node_pool = true
  initial_node_count       = 1
  
  # 網路設定
  network    = "default"
  subnetwork = "default"
  
  # 安全設定
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  
  # 工作負載身份
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  depends_on = [google_project_service.required_apis]
  
  # 防止因版本升級導致重建
  lifecycle {
    ignore_changes = [
      node_config,
      initial_node_count,
    ]
  }
}

# -----------------------------------------------------------------------------
# Node Pool Configuration
# 節點池設定
# -----------------------------------------------------------------------------

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  
  # 節點數量設定
  initial_node_count = var.node_count
  
  # 自動擴縮設定 (可選)
  autoscaling {
    min_node_count = 1
    max_node_count = var.max_node_count
  }
  
  # 節點設定
  node_config {
    preemptible  = var.use_preemptible  # 使用可搶佔節點可省錢
    machine_type = var.machine_type
    disk_size_gb = 15
    disk_type    = "pd-standard"  # 使用 HDD 避免 SSD 配額問題
    
    # 預設 Service Account
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    
    labels = {
      env     = var.environment
      project = var.project_id
    }
    
    tags = ["gke-node", var.cluster_name]
    
    # 工作負載身份
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
  
  # 升級策略
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  depends_on = [google_container_cluster.primary]
}

# -----------------------------------------------------------------------------
# Kubernetes Namespace (已移除)
# 使用 default namespace，不需要額外建立
# 如需自訂 namespace，取消註解下方資源並修改 k8s_namespace 變數
# -----------------------------------------------------------------------------

# resource "kubernetes_namespace" "app" {
#   metadata {
#     name = var.k8s_namespace
#     
#     labels = {
#       app = "cloud-app"
#       env = var.environment
#     }
#   }
#   
#   depends_on = [google_container_node_pool.primary_nodes]
# }

# -----------------------------------------------------------------------------
# Output Values
# 輸出值
# -----------------------------------------------------------------------------

output "cluster_name" {
  description = "GKE Cluster 名稱"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "GKE Cluster endpoint"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_region" {
  description = "Cluster 所在區域"
  value       = var.region
}

output "kubectl_command" {
  description = "連接到 GKE Cluster 的指令"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
}

output "gcr_repository" {
  description = "Google Container Registry 路徑"
  value       = "gcr.io/${var.project_id}"
}

output "next_steps" {
  description = "下一步操作指引"
  value       = <<-EOT
    
    ✅ GKE Cluster 已成功建立！
    
    接下來請執行以下步驟：
    
    1. 連接到 Cluster:
       gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}
    
    2. 建置並推送 Docker 映像:
       docker build -t gcr.io/${var.project_id}/backend-api:latest ./backend-api
       docker build -t gcr.io/${var.project_id}/ad-service:latest ./ad-service
       docker build -t gcr.io/${var.project_id}/frontend-vue:latest ./frontend-vue
       
       docker push gcr.io/${var.project_id}/backend-api:latest
       docker push gcr.io/${var.project_id}/ad-service:latest
       docker push gcr.io/${var.project_id}/frontend-vue:latest
    
    3. 更新 k8s-gke 設定檔中的 PROJECT_ID:
       sed -i '' "s/YOUR_PROJECT_ID/${var.project_id}/g" k8s-gke/*.yaml
    
    4. 部署應用程式:
       kubectl apply -f k8s-gke/
    
  EOT
}
