# =============================================================================
# Terraform Variables
# 變數定義
# =============================================================================

# -----------------------------------------------------------------------------
# Required Variables (必要變數)
# 這些變數必須在 terraform.tfvars 中設定
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "Google Cloud Project ID (GCP 專案 ID)"
  type        = string
  
  validation {
    condition     = length(var.project_id) > 0
    error_message = "Project ID 不能為空。"
  }
}

variable "credentials_file" {
  description = "Service Account JSON 金鑰檔案路徑"
  type        = string
  default     = "credentials.json"
}

# -----------------------------------------------------------------------------
# Optional Variables (可選變數)
# 這些變數有預設值，可依需求覆寫
# -----------------------------------------------------------------------------

variable "region" {
  description = "GCP 區域 (Region)"
  type        = string
  default     = "europe-west1"  # 歐洲區域，適合 HTWG 專案
}

variable "cluster_name" {
  description = "GKE Cluster 名稱"
  type        = string
  default     = "cloud-app-cluster"
}

variable "environment" {
  description = "部署環境 (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment 必須是 dev, staging, 或 prod。"
  }
}

variable "k8s_namespace" {
  description = "Kubernetes Namespace"
  type        = string
  default     = "default"
}

# -----------------------------------------------------------------------------
# Node Pool Configuration (節點池設定)
# -----------------------------------------------------------------------------

variable "machine_type" {
  description = "GKE Node 機器類型"
  type        = string
  default     = "e2-medium"  # 2 vCPU, 4GB RAM - 適合開發測試
  
  # 其他選項：
  # e2-small     : 2 vCPU, 2GB RAM  (最省錢)
  # e2-medium    : 2 vCPU, 4GB RAM  (推薦開發)
  # e2-standard-2: 2 vCPU, 8GB RAM  (標準版)
  # e2-standard-4: 4 vCPU, 16GB RAM (適合生產環境)
}

variable "node_count" {
  description = "初始節點數量"
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "最大節點數量 (用於自動擴縮)"
  type        = number
  default     = 4
}

variable "use_preemptible" {
  description = "是否使用可搶佔 (Preemptible) 節點以節省成本"
  type        = bool
  default     = true  # 開發環境建議開啟，可省 60-80% 成本
}

# -----------------------------------------------------------------------------
# Application Secrets (應用程式機密)
# -----------------------------------------------------------------------------

variable "gemini_api_key" {
  description = "Google Gemini API Key (用於 AI 功能)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "gcp_service_account_json" {
  description = "GCP Service Account JSON (用於後端服務)"
  type        = string
  default     = ""
  sensitive   = true
}
