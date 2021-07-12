#!/bin/bash
set -euo pipefail

body='{
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "disableLocalAuth": true,
    "publicNetworkAccess": "Disabled",
    "restrictOutboundNetworkAccess": true,
    "allowedFqdnList": '$json_allow_list'
  }
}'
url="https://management.azure.com$cognitive_account_id?api-version=2021-04-30"
token="$(az account get-access-token --query accessToken --output tsv)"

# Path the Cognitive Services Account w/ properties currently not available in TF
echo Updating Cognitive Services Account...
location="$(curl -i -s \
  -H 'Content-Type: application/json' -H "Authorization: Bearer $token" \
  -X PATCH -d "$body" "$url" \
  | grep -i '^location:' | sed 's/location: //i; s/\r//')"

# Poll for completion of async operation
while [ -n "$location" ]
do
  http_code="$(curl -s -o /dev/null -w "%{http_code}" \
    -H 'Content-Type: application/json' -H "Authorization: Bearer $token" "$location")"

  [ "$http_code" != "200" ] || break

  echo Still updating Cognitive Services Account...
  sleep 10
done
