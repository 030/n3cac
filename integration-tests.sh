#!/bin/bash -e

nexus(){
  source <(curl -L https://gist.githubusercontent.com/030/666c99d8fc86e9f1cc0ad216e0190574/raw/c5faae82960c46c232a099231166e1b2fc3bb0bb/nexus-docker.sh)
}

delete(){
  echo "Deleting repositories..."
  for r in maven-public maven-central maven-releases maven-snapshots nuget-group nuget-hosted nuget.org-proxy; do curl -u admin:$PASSWORD -X DELETE "http://localhost:9999/service/rest/beta/repositories/${r}" -H  "accept: application/json" -v; done
}

main(){
  nexus
  delete
}

main
