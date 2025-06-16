## Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
## SPDX-License-Identifier: MIT-0

# Karpenter default EC2NodeClass and NodePool
resource "kubectl_manifest" "karpenter_default_ec2_node_class" {
  yaml_body = <<YAML
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: default
spec:
  role: "${local.node_iam_role_name}"
  amiSelectorTerms:
    - alias: al2023@latest
  securityGroupSelectorTerms:
  - tags:
      karpenter.sh/discovery: ${local.cluster_name}
  subnetSelectorTerms:
  - tags:
      karpenter.sh/discovery: ${local.cluster_name}
  tags:
    IntentLabel: apps
    KarpenterNodePoolName: default
    NodeType: default
    intent: apps
    karpenter.sh/discovery: ${local.cluster_name}
    project: karpenter-blueprints
YAML
  depends_on = [
    module.eks.cluster,
    module.eks_blueprints_addons.karpenter,
  ]
}



resource "kubectl_manifest" "karpenter_cuttlefish_ec2_node_class" {
  yaml_body = <<YAML
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: cuttlefish
spec:
  amiSelectorTerms:
    - alias: al2023@latest
  blockDeviceMappings:
    - deviceName: '/dev/xvda'
      rootVolume: true
      ebs:
        volumeType: gp3
        volumeSize: 500Gi
  role: "${local.node_iam_role_name}" 
  securityGroupSelectorTerms:
  - tags:
      karpenter.sh/discovery: ${local.cluster_name}
  subnetSelectorTerms:
  - tags:
      karpenter.sh/discovery: ${local.cluster_name}
  userData: |
    sudo modprobe vhost_vsock
    sudo modprobe vhost_net
YAML
  depends_on = [
    module.eks.cluster,
    module.eks_blueprints_addons.karpenter,
  ]
}

resource "kubectl_manifest" "karpenter_cuttlefish_node_pool" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: cuttlefish
spec:
  template:
    spec:
      taints:
        - key: android
          effect: NoSchedule
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["arm64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: node.kubernetes.io/instance-type
          operator: In
          values: ["c8g.metal-24xl"]
      nodeClassRef:
        group: karpenter.k8s.aws  
        kind: EC2NodeClass
        name: cuttlefish
YAML
  depends_on = [
    module.eks.cluster,
    module.eks_blueprints_addons.karpenter,
    kubectl_manifest.karpenter_cuttlefish_ec2_node_class,
  ]
}

resource "kubectl_manifest" "karpenter_cuttlefish_spot_node_pool" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: cuttlefish-spot
spec:
  template:
    spec:
      taints:
        - key: android
          effect: NoSchedule
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["arm64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
        - key: node.kubernetes.io/instance-type
          operator: In
          values: ["c8g.metal-24xl"]
      nodeClassRef:
        group: karpenter.k8s.aws  
        kind: EC2NodeClass
        name: cuttlefish
YAML
  depends_on = [
    module.eks.cluster,
    module.eks_blueprints_addons.karpenter,
    kubectl_manifest.karpenter_cuttlefish_ec2_node_class,
  ]
}

resource "kubectl_manifest" "karpenter_default_node_pool" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: default 
spec:  
  template:
    metadata:
      labels:
        intent: apps
    spec:
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["4", "8", "16", "32", "48", "64"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot", "on-demand"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["c", "m", "r"]
      nodeClassRef:
        group: karpenter.k8s.aws  
        kind: EC2NodeClass
        name: default
YAML
  depends_on = [
    module.eks.cluster,
    module.eks_blueprints_addons.karpenter,
    kubectl_manifest.karpenter_default_ec2_node_class,
  ]
}
