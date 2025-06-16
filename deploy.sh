// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
cd terraform

terraform apply -target="module.vpc" -auto-approve
terraform apply -target="module.eks" -auto-approve

docker logout public.ecr.aws
terraform apply --auto-approve

aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true


AWS_REGION=$(terraform output -raw region)
AWS_CLUSTER_NAME=$(terraform output -raw cluster_name)
aws eks update-kubeconfig --region $AWS_REGION --name $AWS_CLUSTER_NAME

cd ..
kubectl apply -k manifests