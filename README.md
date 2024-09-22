
# **EKS Cluster Setup and CodeBuild Integration**

## **Project Overview**

This project involves setting up an Amazon Elastic Kubernetes Service (EKS) cluster on AWS and integrating it with AWS CodeBuild for continuous integration and deployment. The project also includes configurations for logging, authentication, and database management.

---

## **1. Infrastructure Setup**

### **Create an EKS Cluster**

To create an EKS cluster using `eksctl`, follow the steps below. First, ensure you have `eksctl` installed on your machine. Refer to the official [eksctl installation guide](https://eksctl.io/installation/).

Run the following command to create your EKS cluster:

```bash
eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t2.small --nodes 1 --nodes-min 1 --nodes-max 2
```

Once the cluster is created, update your kubeconfig:

```bash
aws eks --region us-east-1 update-kubeconfig --name my-cluster
```

---

## **2. AWS CodeBuild Configuration**

To set up AWS CodeBuild, run the following command to update the build project environment variables:

```bash
aws codebuild update-project --name YOUR_PROJECT_NAME --environment-variables '[ 
  {"name": "AWS_DEFAULT_REGION", "value": "us-east-1", "type": "PLAINTEXT"},  
  {"name": "AWS_ACCOUNT_ID", "value": "010928182936", "type": "PLAINTEXT"},  
  {"name": "IMAGE_REPO_NAME", "value": "coworking-project3", "type": "PLAINTEXT"},  
  {"name": "DOCKER_BUILDKIT", "value": "1", "type": "PLAINTEXT"},  
  {"name": "BUILDKIT_INLINE_CACHE", "value": "1", "type": "PLAINTEXT"}]'
```

### **CodeBuild IAM Permissions**

If your build fails due to missing IAM permissions, follow these steps:

1. Go to the [IAM Console](https://console.aws.amazon.com/iam/home).
2. Under **Roles**, find the role used by CodeBuild (e.g., `codebuild-my-codebuild-service-role`).
3. Attach the following permissions to allow ECR access for pulling and pushing Docker images:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    }
  ]
}
```

To allow pushing images to a specific ECR repository, use the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": "arn:aws:ecr:us-east-1:010928182936:repository/coworking-project3"
    }
  ]
}
```

---

## **3. Testing and Monitoring**

### **Test API**

Once your application is running, you can test it by curling the API endpoint:

```bash
curl 127.0.0.1:5153/api/reports/daily_usage
```

### **Database Management (PostgreSQL)**

To view the pods in your cluster:

```bash
kubectl get pods
```

To access the PostgreSQL pod (assuming its name is `postgresql-6889d46b98-bd84h`):

```bash
kubectl exec -it postgresql-6889d46b98-bd84h -- bash
```

Inside the pod, connect to the PostgreSQL database:

```bash
psql -U myuser -d mydatabase
```

Once connected, you can list all databases using:

```bash
\l
```

---

## **4. Apply Kubernetes Resources**

To deploy your application using Kubernetes, apply the configuration:

```bash
kubectl apply -f coworking.yaml
```

---

## **5. Enable EKS Cluster Logging**

Enable CloudWatch logging for your EKS cluster to monitor the control plane and other components:

```bash
aws eks update-cluster-config     --region us-east-1     --name my-cluster     --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}'
```

---

## **Conclusion**

This README provides a step-by-step guide for creating an EKS cluster, configuring CodeBuild, interacting with your Kubernetes resources, and enabling logging for better observability. Follow these instructions to deploy your application and manage your infrastructure effectively.

