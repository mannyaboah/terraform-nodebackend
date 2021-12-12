# terrafom-node-apps-gke

## To run:

Open Google Cloud Shell and clone this repository.

Open terraform.tfvars file and change project_id variable to your project ID. 
If you comment out that line you will be prompted for the Project ID.

## Then run: 
terraform init

terraform plan

terraform apply -auto-approve

## The followng will be created:
- GKE Cluster

- Kubernetes namespace

- Kubernetes nodebacked app deployment

- Kubernetes nodebacked app ClusterIp

- Kubernetes nodeFrontend app deployment

- Kubernetes nodebacked app load balancer


## To delete everything run:
terraform destroy -auto-approve
