#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${SCRIPT_DIR}/../charts"
helm repo index .

export HELM_REGISTRY_REFERENCE="registry-1.docker.io/bougoucharts"

yq eval -i '. |= .entries[][] |= .urls[0] = "oci://" + env(HELM_REGISTRY_REFERENCE) + "/" + .name + ":" + .version' index.yaml

mv index.yaml ../
