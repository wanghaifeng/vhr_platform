# Primary Kubernetes Cluster
resource "alicloud_cs_managed_kubernetes" "primary" {
  name                         = "${var.cluster_name}-primary"
  vswitch_ids                  = var.vswitch_ids
  new_nat_gateway              = true
  node_cidr_mask               = "25"
  proxy_mode                   = "ipvs"
  service_cidr                 = var.service_cidr
  pod_cidr                     = var.pod_cidr
  security_group_id            = var.security_group_id
  is_enterprise_security_group = false
  # Fixed: Use NLB as entry point, so disable default public SLB to save cost
  slb_internet_enabled = false

  # Kubernetes version
  version = var.k8s_version

  # Addons
  addons {
    name = "terway-eniip"
  }

  addons {
    name = "csi-plugin"
  }

  addons {
    name = "csi-provisioner"
  }

  addons {
    name = "logtail-ds"
    config = jsonencode({
      IngressDashboardEnabled = "true"
      log_store               = "k8s-log"
    })
  }

  # Maintenance window
  maintenance_window {
    enable           = true
    maintenance_time = var.maintenance_time
    duration         = "4"
    weekly_period    = "Mon,Tue,Wed,Thu,Fri"
  }

  tags = merge(var.tags, {
    role = "primary"
    type = "kubernetes-cluster"
  })
}

# Istio Service Mesh Addon - Primary Cluster
resource "alicloud_cs_kubernetes_addon" "istio_primary" {
  count     = var.enable_istio ? 1 : 0
  cluster_id = alicloud_cs_managed_kubernetes.primary.id
  name       = "istio"
  version    = var.istio_version != "" ? var.istio_version : null
}

# Istio Service Mesh Addon - Secondary Cluster (DR)
resource "alicloud_cs_kubernetes_addon" "istio_secondary" {
  count     = var.enable_istio && var.enable_dr ? 1 : 0
  cluster_id = alicloud_cs_managed_kubernetes.secondary[0].id
  name       = "istio"
  version    = var.istio_version != "" ? var.istio_version : null
}

# Secondary Kubernetes Cluster (DR)
resource "alicloud_cs_managed_kubernetes" "secondary" {
  count = var.enable_dr ? 1 : 0

  name                         = "${var.cluster_name}-secondary"
  vswitch_ids                  = var.dr_vswitch_ids
  new_nat_gateway              = true
  node_cidr_mask               = "25"
  proxy_mode                   = "ipvs"
  service_cidr                 = var.dr_service_cidr
  pod_cidr                     = var.dr_pod_cidr
  security_group_id            = var.security_group_id
  is_enterprise_security_group = false
  slb_internet_enabled         = false

  version = var.k8s_version

  addons {
    name = "terway-eniip"
  }

  addons {
    name = "csi-plugin"
  }

  addons {
    name = "csi-provisioner"
  }

  addons {
    name = "logtail-ds"
    config = jsonencode({
      IngressDashboardEnabled = "true"
      log_store               = "k8s-log"
    })
  }

  # Maintenance window
  maintenance_window {
    enable           = true
    maintenance_time = var.maintenance_time
    duration         = "4"
    weekly_period    = "Mon,Tue,Wed,Thu,Fri"
  }

  tags = merge(var.tags, {
    role = "secondary"
    type = "kubernetes-cluster"
  })
}

# Primary Cluster Node Pool
resource "alicloud_cs_kubernetes_node_pool" "primary_workers" {
  node_pool_name = "${var.cluster_name}-primary-workers"
  cluster_id     = alicloud_cs_managed_kubernetes.primary.id
  vswitch_ids    = var.vswitch_ids
  instance_types = var.node_instance_types
  desired_size   = var.node_count
  key_name       = var.key_name

  system_disk_category = "cloud_essd"
  system_disk_size     = var.system_disk_size

  data_disks {
    category = "cloud_essd"
    size     = var.data_disk_size
  }

  # Autoscaling configuration
  dynamic "scaling_config" {
    for_each = var.enable_autoscaling ? [1] : []
    content {
      min_size = var.min_node_count
      max_size = var.max_node_count
    }
  }

  dynamic "labels" {
    for_each = merge(var.node_labels, {
      cluster = "primary"
      role    = "worker"
    })
    content {
      key   = labels.key
      value = labels.value
    }
  }

  dynamic "taints" {
    for_each = var.node_taints
    content {
      key    = taints.key
      value  = taints.value
      effect = taints.effect
    }
  }
}

# Secondary Cluster Node Pool
resource "alicloud_cs_kubernetes_node_pool" "secondary_workers" {
  count = var.enable_dr ? 1 : 0

  node_pool_name = "${var.cluster_name}-secondary-workers"
  cluster_id     = alicloud_cs_managed_kubernetes.secondary[0].id
  vswitch_ids    = var.dr_vswitch_ids
  instance_types = var.node_instance_types
  desired_size   = var.node_count
  key_name       = var.key_name

  system_disk_category = "cloud_essd"
  system_disk_size     = var.system_disk_size

  data_disks {
    category = "cloud_essd"
    size     = var.data_disk_size
  }

  # Autoscaling configuration
  dynamic "scaling_config" {
    for_each = var.enable_autoscaling ? [1] : []
    content {
      min_size = var.min_node_count
      max_size = var.max_node_count
    }
  }

  dynamic "labels" {
    for_each = merge(var.node_labels, {
      cluster = "secondary"
      role    = "worker"
    })
    content {
      key   = labels.key
      value = labels.value
    }
  }

  dynamic "taints" {
    for_each = var.node_taints
    content {
      key    = taints.key
      value  = taints.value
      effect = taints.effect
    }
  }
}
