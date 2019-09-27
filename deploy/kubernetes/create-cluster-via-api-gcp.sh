#!/bin/bash

# production environment
echo "Environment set to PRODUCTION"
BEARERID=$(cat nks-api.token)
API_ENDPOINT="https://api.nks.netapp.io"

ORGANISATION="DevOps-Orga"
OWNER="Owner Name"
WORKSPACE="DevOps-Workspace"
KEYSET="netapp-kubernetes-user"
SSHSET=""
CVSSET=""
CLUSTERNAME="techforum-hd-gcp"
K8S_VERSION="v1.15.3"
  

# Get all organizations
ORG_ID=$(curl -s -X GET "$API_ENDPOINT/orgs" -H "Authorization: Bearer $BEARERID" | \
 jq --arg ORGANISATION "$ORGANISATION" '.[] | select(.name == $ORGANISATION).pk')
echo "Organisation: $ORGANISATION - ID: $ORG_ID"

# Get owner
OWNER_ID=$(curl -s -X GET "$API_ENDPOINT/orgs/$ORG_ID/members" -H "Authorization: Bearer $BEARERID" | \
 jq --arg OWNER "$OWNER" '.[] | select(.org == '$ORG_ID' and .user.full_name == $OWNER).user.pk')
echo "Owner: $OWNER - ID: $OWNER_ID"

# Get workspace
WS_ID=$(curl -s -X GET "$API_ENDPOINT/orgs/$ORG_ID/workspaces" -H "Authorization: Bearer $BEARERID" | \
 jq --arg WORKSPACE "$WORKSPACE" '.[] | select(.name == $WORKSPACE).pk')
echo "Workspace: $WORKSPACE - ID: $WS_ID"

# Get keyset
KEY_ID=$(curl -s -X GET "$API_ENDPOINT/orgs/$ORG_ID/keysets" -H "Authorization: Bearer $BEARERID" | \
 jq --arg KEYSET "$KEYSET" '.[] | select (.category == "provider") | select(.name == $KEYSET).pk')
echo "Keyset: $KEYSET - ID: $KEY_ID"

# Get SSH key
#SSH_ID=$(curl -s -X GET "$API_ENDPOINT/orgs/$ORG_ID/keysets" -H "Authorization: Bearer $BEARERID" | \
# jq --arg SSHSET "$SSHSET" '.[] | select (.category == "user_ssh") | select (.name == $SSHSET).pk')
#echo "SSH: $SSHSET - ID: $SSH_ID"

# Get CVS solutions key
# CVS_ID=$(curl -s -X GET "$API_ENDPOINT/orgs/$ORG_ID/keysets" -H "Authorization: Bearer $BEARERID" | \
# jq --arg CVSSET "$CVSSET" '.[] | select (.category == "solution" and .entity == "cvsaws") | select (.name == $CVSSET).pk')
#echo "CVS: $CVSSET - ID: $CVS_ID"

# Get clusters
curl -s -X GET "$API_ENDPOINT/orgs/$ORG_ID/clusters" -H "Authorization: Bearer $BEARERID" | jq '.[] | "\(.pk) \(.name)"' 
echo "Creating new cluster ($K8S_VERSION) in 10s. Press ctrl-c to abort ..."
# sleep 10

# Build NKS-Demo cluster
GCE_JSON=$(
    jq -n \
    --argjson WS_ID "$WS_ID" \
    --argjson OWNER_ID "$OWNER_ID" \
    --argjson KEY_ID "$KEY_ID" \
    --argjson SSH_ID "$SSH_ID" \
    --arg CLUSTERNAME "$CLUSTERNAME" \
    --arg K8S_VERSION "$K8S_VERSION" \
'{
  "name": $CLUSTERNAME,
  "provider": "gce",
  "workspace": $WS_ID,
  "provider_keyset": $KEY_ID,
  "master_count": 1,
  "master_size": "n1-standard-2",
  "master_root_disk_size": 50,
  "master_gpu_instance_size": "",
  "master_gpu_core_count": null,
  "worker_count": 2,
  "worker_size": "n1-standard-2",
  "worker_gpu_instance_size": "",
  "worker_gpu_core_count": null,
  "worker_root_disk_size": 50,
  "k8s_version": $K8S_VERSION,
  "k8s_dashboard_enabled": true,
  "k8s_rbac_enabled": true,
  "k8s_pod_cidr": "10.2.0.0",
  "k8s_service_cidr": "10.3.0.0",
  "project_id": "",
# "user_ssh_keyset": $SSH_ID,
  "user_ssh_keyset": null,
  "etcd_type": "classic",
  "platform": "ubuntu",
  "channel": "18.04-lts",
  "region": "europe-west3-a",
  "zone": "",
  "config": {
    "enable_experimental_features": true
  },
  "provider_network_id": "",
  "provider_network_cidr": "",
  "provider_subnet_id": "",
  "provider_subnet_cidr": "",
  "network_components": [],
  "provider_resource_group": "",
  "solutions": [
    {
      "solution": "helm_tiller",
      "name": "Helm Tiller",
      "installer": "",
      "keysetRequired": false,
      "keyset": null,
      "mode": null,
      "tag": "latest",
      "config": {},
      "spec": {},
      "dependencies": [],
      "version": "latest"
    }
  ],
  "features": [],
  "min_node_count": null,
  "max_node_count": null,
  "owner": $OWNER_ID    
}'
)
curl -s --header "Authorization: Bearer $BEARERID" \
     --header "Content-Type: application/json" \
     --header "Accept: application/json" \
     --request POST \
     --data "$GCE_JSON" \
     $API_ENDPOINT/orgs/$ORG_ID/workspaces/$WS_ID/clusters > cluster.json
CLUSTER_ID=$(cat cluster.json | jq '.pk')
cat cluster.json | jq '"\(.pk) \(.name)"'   
