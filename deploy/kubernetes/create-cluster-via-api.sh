#!/bin/bash

BEARERID=$(cat nks-token.txt)
API_ENDPOINT="https://api.nks.netapp.io"
ORGANISATION="DevOps-Orga"
WORKSPACE="DevOps-Workspace"
KEYSET="netapp-kubernetes-user"
CLUSTERNAME="techforum-hd-2"
K8S_VERSION="v1.15.3"

# Get all organizations
ORG_ID=$(curl -s -X GET "$API_ENDPOINT/orgs" -H "Authorization: Bearer $BEARERID" | \
 jq '.[] | select(.name == "'$ORGANISATION'").pk')
echo "Organisation: $ORGANISATION - ID: $ORG_ID"

# Get workspace
WS_ID=$(curl -s -X GET "$API_ENDPOINT/orgs/$ORG_ID/workspaces" -H "Authorization: Bearer $BEARERID" |
 jq '.[] | select(.name == "'$WORKSPACE'").pk')
echo "Workspace: $WORKSPACE - ID: $WS_ID"

# Get owner
OWNER_ID=$(curl -s -X GET "$API_ENDPOINT/orgs/$ORG_ID/members" -H "Authorization: Bearer $BEARERID" |
 jq '.[] | select(.org == '$ORG_ID' and .user.full_name == "Simon Heger").user.pk')
echo "Owner: $OWNER - ID: $OWNER_ID"

# Get keyset
KEY_ID=$(curl -s -X GET "$API_ENDPOINT/orgs/$ORG_ID/keysets" -H "Authorization: Bearer $BEARERID" | \
 jq '.[] | select (.category == "provider") | select(.name == "'$KEYSET'").pk')
echo "Keyset: $KEYSET - ID: $KEY_ID"

# Get SSH key
SSH_ID=$(curl -s -X GET "$API_ENDPOINT/orgs/$ORG_ID/keysets" -H "Authorization: Bearer $BEARERID" | \
 jq '.[] | select (.category == "user_ssh") | select (.name == "Default SPC SSH Keypair").pk')
echo "SSH: $SSHSET - ID: $SSH_ID"

# Get clusters
printf "\nList existing clusters\n"
curl -s -X GET "$API_ENDPOINT/orgs/$ORG_ID/clusters" -H "Authorization: Bearer $BEARERID" | jq '.[] | "\(.pk) \(.name)"'

printf "\nCreating new cluster ($K8S_VERSION)\n"

AWS_JSON=$(
    jq -n \
    --argjson WS_ID "$WS_ID" \
    --argjson OWNER_ID "$OWNER_ID" \
    --argjson KEY_ID "$KEY_ID" \
    --argjson SSH_ID "$SSH_ID" \
    --arg CLUSTERNAME "$CLUSTERNAME" \
    --arg K8S_VERSION "$K8S_VERSION" \
'{
  "name": $CLUSTERNAME,
  "provider": "aws",
  "workspace": $WS_ID,
  "provider_keyset": $KEY_ID,
  "master_count": 1,
  "master_size": "t2.medium",
  "master_root_disk_size": 50,
  "master_gpu_instance_size": "",
  "master_gpu_core_count": null,
  "worker_count": 2,
  "worker_size": "t2.medium",
  "worker_gpu_instance_size": "",
  "worker_gpu_core_count": null,
  "worker_root_disk_size": 50,
  "k8s_version": $K8S_VERSION,
  "k8s_dashboard_enabled": true,
  "k8s_rbac_enabled": true,
  "k8s_pod_cidr": "10.2.0.0",
  "k8s_service_cidr": "10.3.0.0",
  "project_id": "",
  "user_ssh_keyset": $SSH_ID,
  "etcd_type": "classic",
  "platform": "coreos",
  "channel": "stable",
  "region": "us-east-1",
  "zone": "us-east-1a",
  "config": {enable_experimental_features: true},
  "provider_network_id": "vpc-0c20454fd2c589945",
  "provider_network_cidr": "172.16.0.0/16",
  "provider_subnet_id": "subnet-000b4821d29589423",
  "provider_subnet_cidr": "172.16.1.0/24",
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
  "owner": $OWNER_ID,
  "user_solution_revisions": []
}'
)
curl -s --header "Authorization: Bearer $BEARERID" \
     --header "Content-Type: application/json" \
     --header "Accept: application/json" \
     --request POST \
     --data "$AWS_JSON" \
     $API_ENDPOINT/orgs/$ORG_ID/workspaces/$WS_ID/clusters > cluster.json
CLUSTER_ID=$(cat cluster.json | jq '.pk')
cat cluster.json | jq '"\(.pk) \(.name)"'
