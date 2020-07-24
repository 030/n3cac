#!/bin/bash -e

nexus(){
  source <(curl -L https://gist.githubusercontent.com/030/666c99d8fc86e9f1cc0ad216e0190574/raw/c5faae82960c46c232a099231166e1b2fc3bb0bb/nexus-docker.sh)
}

delete(){
  echo "Deleting repositories..."
  for r in maven-public maven-central maven-releases maven-snapshots nuget-group nuget-hosted nuget.org-proxy; do curl -u admin:$PASSWORD -X DELETE "http://localhost:9999/service/rest/beta/repositories/${r}" -H  "accept: application/json" -v; done
}


create(){
  echo "Creating repositories..."
  curl -u admin:$PASSWORD -X POST "http://localhost:9999/service/rest/beta/repositories/maven/hosted" \
-H  "accept: application/json" \
-H  "Content-Type: application/json" \
--data '{"name":"REPO_NAME","online":true,"storage":{"blobStoreName":"default","strictContentTypeValidation":true,"writePolicy":"ALLOW_ONCE"},"maven": {"versionPolicy": "RELEASE","layoutPolicy": "STRICT"}}'
}

main(){
  nexus
  delete
  create
}

main
