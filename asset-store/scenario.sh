#This script contains all methods to configure azure blob as us storage

# Custom parameters
export AZ_ACCOUNT_NAME=new_account_name
export AZ_RESOURCE_GROUP=group_name
export AZ_RESOURCE_GROUP_LOCATION=westeurope
export AZ_SUBSCRIPTION=subscription_id

# Create Resource Group
az group create --name ${AZ_RESOURCE_GROUP} --location ${AZ_RESOURCE_GROUP_LOCATION} --subscription ${AZ_SUBSCRIPTION}

# Create Storage Account
az storage account create --name ${AZ_ACCOUNT_NAME} --resource-group ${AZ_RESOURCE_GROUP} --subscription ${AZ_SUBSCRIPTION}

# Get secret key
export AZ_ACCOUNT_KEY=$(az storage account keys list --account-name "${AZ_ACCOUNT_NAME}" --resource-group "${AZ_RESOURCE_GROUP}" --query "[?keyName=='key1'].value" --output tsv | base64)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: asset-store-overrides
  namespace: kyma-installer
  labels:
    installer: overrides
    component: assetstore
    kyma-project.io/installation: ""
type: Opaque
data:
  minio.accessKey: "$(echo "${AZ_ACCOUNT_NAME}" | base64)"
  minio.secretKey: "${AZ_ACCOUNT_KEY}"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: asset-store-overrides
  namespace: kyma-installer
  labels:
    installer: overrides
    component: assetstore
    kyma-project.io/installation: ""
data:
  minio.persistence.enabled: "false"
  minio.azuregateway.enabled: "true"
  minio.DeploymentUpdate.type: RollingUpdate
  minio.DeploymentUpdate.maxSurge: "0"
  minio.DeploymentUpdate.maxUnavailable: "50%"
EOF

kubectl label installation/kyma-installation action=install