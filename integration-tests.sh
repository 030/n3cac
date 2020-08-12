#!/bin/bash -e

NEXUS_VERSION="${1:-3.25.0}"

nexus(){
  curl -L https://gist.githubusercontent.com/030/666c99d8fc86e9f1cc0ad216e0190574/raw/df8c3140bbfe5a737990b0f4e96594851171f491/nexus-docker.sh -o start.sh
  chmod +x start.sh
  source ./start.sh $NEXUS_VERSION
}

delete(){
  echo "Deleting repositories..."
  for r in maven-public maven-central maven-releases maven-snapshots nuget-group nuget-hosted nuget.org-proxy; do curl -u admin:$PASSWORD -X DELETE "http://localhost:9999/service/rest/beta/repositories/${r}" -H  "accept: application/json" -v; done
}

createHostedMaven(){
  echo "Creating repositories..."
  curl -u admin:$PASSWORD -X POST "http://localhost:9999/service/rest/beta/repositories/maven/hosted" \
  -H  "accept: application/json" \
  -H  "Content-Type: application/json" \
  --data '{"name":"REPO_NAME","online":true,"storage":{"blobStoreName":"default","strictContentTypeValidation":true,"writePolicy":"ALLOW_ONCE"},"maven": {"versionPolicy": "RELEASE","layoutPolicy": "STRICT"}}'
}

createHostedMavenSnapshots(){
  echo "Creating Maven Hosted Snapshot repository..."
  curl -u admin:$PASSWORD \
       -X POST "http://localhost:9999/service/rest/beta/repositories/maven/hosted" \
       -H  "accept: application/json" \
       -H  "Content-Type: application/json" \
       --data '{"name":"REPO_NAME_MAVEN_SNAPSHOTS","online":true,"storage":{"blobStoreName":"default","strictContentTypeValidation":true,"writePolicy":"ALLOW"},"maven": {"versionPolicy": "SNAPSHOT","layoutPolicy": "STRICT"}}'
}

createHostedApt(){
  echo "Creating Hosted Apt proxy..."
  curl -u admin:$PASSWORD -X POST "http://localhost:9999/service/rest/beta/repositories/apt/hosted" \
  -H  "accept: application/json" \
  -H  "Content-Type: application/json" \
  --data '{"name":"REPO_NAME_HOSTED_APT","online":true,"proxy":{"remoteUrl":"http://nl.archive.ubuntu.com/ubuntu/"},"storage":{"blobStoreName":"default","strictContentTypeValidation":true,"writePolicy":"ALLOW_ONCE"},"apt": {"distribution": "bionic"},"aptSigning": {"keypair": "string","passphrase": "string"}}'
}

anonymous(){
  echo "Disable anonymous access..."
  curl -u admin:$PASSWORD -X PUT "http://localhost:9999/service/rest/beta/security/anonymous" \
-H  "accept: application/json" \
-H  "Content-Type: application/json" \
--data '{"enabled":false}'
}

createAptProxy(){
  echo "Creating Apt proxy..."
  curl -u admin:$PASSWORD -X POST "http://localhost:9999/service/rest/beta/repositories/apt/proxy" \
    -H  "accept: application/json" \
    -H  "Content-Type: application/json" \
    --data '{"name":"REPO_NAME_APT_PROXY","online":true,"proxy":{"remoteUrl":"http://nl.archive.ubuntu.com/ubuntu/","contentMaxAge": 1440,"metadataMaxAge": 1440},"storage":{"blobStoreName":"default","strictContentTypeValidation":true,"writePolicy":"ALLOW_ONCE"},"apt": {"distribution": "bionic","flat":false},"negativeCache": {"enabled": true,"timeToLive": 1440},"httpClient": {"blocked": false,"autoBlock": true}}'
}

createMavenProxy(){
  echo "Creating Maven proxy..."
  curl -v -u admin:$PASSWORD -X POST "http://localhost:9999/service/rest/beta/repositories/maven/proxy" \
       -H  "accept: application/json" \
       -H  "Content-Type: application/json" \
       --data "{\"name\": \"${1}\",\"online\": true,\"storage\": {\"blobStoreName\": \"default\",\"strictContentTypeValidation\": true},\"cleanup\": {\"policyNames\": [\"string\"]},\"proxy\": {\"remoteUrl\": \"${2}\",\"contentMaxAge\": 1440,\"metadataMaxAge\": 1440},\"negativeCache\": {\"enabled\": false,\"timeToLive\": 1440}, \"httpClient\": {\"blocked\": false,\"autoBlock\": true},\"routingRule\": \"string\",\"maven\": {\"versionPolicy\": \"MIXED\",\"layoutPolicy\": \"STRICT\"}}"
}

createMavenProxies(){
  createMavenProxy "3rdparty-maven" "https://repo.maven.apache.org/maven2/"
  createMavenProxy "3rdparty-maven-gradle-plugins" "https://plugins.gradle.org/m2/"
}

createMavenGroup(){
  echo "Creating Maven group and adding members..."
  curl -v -u admin:$PASSWORD -X POST "http://localhost:9999/service/rest/beta/repositories/maven/group" \
       -H  "accept: application/json" \
       -H  "Content-Type: application/json" \
       --data "{\"name\": \"${1}\",\"online\": true,\"storage\": {\"blobStoreName\": \"default\",\"strictContentTypeValidation\": true},\"group\": {\"memberNames\": [${2}]}}"
}

createUser(){
  echo "Creating user..."
  curl -v -u admin:$PASSWORD -X POST "http://localhost:9999/service/rest/beta/security/users" \
       -H  "accept: application/json" \
       -H  "Content-Type: application/json" \
       --data "{\"userId\": \"${1}\",\"firstName\": \"${1}\",\"lastName\": \"${2}\",\"emailAddress\": \"${3}\",\"password\": \"${4}\",\"status\": \"active\",\"roles\": [\"nx-admin\"]}"
}

debug(){
  echo $PASSWORD
  sleep 600
}

main(){
  nexus
  delete
  createHostedMaven
  createHostedMavenSnapshots
  anonymous
  createAptProxy
  createHostedApt
  createMavenProxies
  createMavenGroup someGroup "\"REPO_NAME\",\"REPO_NAME_MAVEN_SNAPSHOTS\""
  createUser hello world hello@gfgfdgfdggdf.nl pass
  debug
}

trap cleanup EXIT
main
