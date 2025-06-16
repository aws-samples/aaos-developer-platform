# AAOS Developer platform on EKS with Karpenter

## Motivation
This project aims to provide a solution to build, run and test Android Automotive OS in the Cloud. The project relies on [Android Cuttlefish Device](https://source.android.com/docs/devices/cuttlefish) to run virtual Android devices. The devices run in a Kubernetes cluster using Karpenter to provide the underlying infrastructure. 

[Karpenter](https://karpenter.sh/), a node provisioning project built for Kubernetes has been helping many companies to improve the efficiency and cost of running workloads on Kubernetes. Karpenter automatically launches just the right compute resources to handle your cluster's applications. It is designed to let you take full advantage of the cloud with fast and simple compute provisioning for Kubernetes clusters.

The project comes with a number of Dockerfiles inside the `ci-images` folder. Those dockerfiles can be used to build the container images needed to run Cuttlefish as a container. 
 * `aws-cli-kubectl-adb` contains a Dockerfile for a container that can be used in a CI/CD pipeline to interact with AWS services, a Kubernetes cluster to provision a cuttlefish device and the ADB tooling to connect to the virtual device.
 * `base-cuttlefish` contains a Dockerfile with all the prerequisite tools needed to run Cuttlefish except the Android OS artifacts. 
 * `target-cuttlefish` builds from the base image, retrieving the Android OS artifacts from an S3 Bucket. This is the image that you run in the cluster to virtualize Android. 

### Requirements

* You need access to an AWS account with IAM permissions to create an EKS cluster.
* Install and configure the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* Install the [Kubernetes CLI (kubectl)](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
* (Optional*) Install the [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* (Optional*) Install Helm ([the package manager for Kubernetes](https://helm.sh/docs/intro/install/))

***NOTE:** If you're planning to use an existing EKS cluster, you don't need the **optional** prerequisites.

#### Create an EKS Cluster using Terraform 


You'll create an Amazon EKS cluster using the [EKS Blueprints for Terraform project](https://github.com/aws-ia/terraform-aws-eks-blueprints). The Terraform template included in this repository is going to create a VPC, an EKS control plane, and a Kubernetes service account along with the IAM role and associate them using IAM Roles for Service Accounts (IRSA) to let Karpenter launch instances. Additionally, the template configures the Karpenter node role to the `aws-auth` configmap to allow nodes to connect, and creates an On-Demand managed node group for the `kube-system` and `karpenter` namespaces.

To create the cluster, clone this repository. Then, run the following commands:

```
cd terraform
helm registry logout public.ecr.aws
export TF_VAR_region=$AWS_REGION
terraform init
terraform apply -target="module.vpc" -auto-approve
terraform apply -target="module.eks" -auto-approve
terraform apply --auto-approve
```

You might need to update the Helm charts available : 
```
helm repo update 
```


Before you continue, you need to enable your AWS account to launch Spot instances if you haven't launch any yet. To do so, create the [service-linked role for Spot](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-requests.html#service-linked-roles-spot-instance-requests) by running the following command:

```
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true
```

You might see the following error if the role has already been successfully created. You don't need to worry about this error, you simply had to run the above command to make sure you have the service-linked role to launch Spot instances:

```
An error occurred (InvalidInput) when calling the CreateServiceLinkedRole operation: Service role name AWSServiceRoleForEC2Spot has been taken in this account, please try a different suffix.
```

Once complete (after waiting about 15 minutes), run the following command to update the `kube.config` file to interact with the cluster through `kubectl`:

```
AWS_REGION=$(terraform output -raw region)
AWS_CLUSTER_NAME=$(terraform output -raw cluster_name)
aws eks update-kubeconfig --region $AWS_REGION --name $AWS_CLUSTER_NAME
```

You need to make sure you can interact with the cluster and that the Karpenter pods are running:

```
$> kubectl get pods -n karpenter
NAME                       READY STATUS  RESTARTS AGE
karpenter-5f97c944df-bm85s 1/1   Running 0        15m
karpenter-5f97c944df-xr9jf 1/1   Running 0        15m
```


#### Deploy your first Cuttlefish device

A deployment is provided as an example to run Cuttlefish. The image is compiled using Android 15.0.0r5. You can also build your own image using the following [instructions](https://source.android.com/docs/devices/cuttlefish/get-started)


#### Terraform Cleanup  (Optional)

Once you're done with testing the blueprints, if you used the Terraform template from this repository, you can proceed to remove all the resources that Terraform created. To do so, run the following commands:

```
kubectl delete --all nodeclaim
kubectl delete --all nodepool
kubectl delete --all ec2nodeclass
export TF_VAR_region=$AWS_REGION
terraform destroy -target="module.eks_blueprints_addons" --auto-approve
terraform destroy -target="module.eks" --auto-approve
terraform destroy --auto-approve
```


## Security
This code is provided as a Proof of Concept, some work should be done before deploying it to a production environment. You can use tools like Checkov to harden the code before running it in production. 
See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.


## License

This library is licensed under the MIT-0 License. See the LICENSE file.
