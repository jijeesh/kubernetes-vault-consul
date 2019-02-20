#!/bin/bash


echo "Generating the Gossip encryption key..."

export GOSSIP_ENCRYPTION_KEY=$(consul keygen)


echo "Creating the Consul Secret to store the Gossip key and the TLS certificates..."

kubectl -n vault create secret generic consul \
  --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
  --from-file=certs/ca.pem \
  --from-file=certs/consul.pem \
  --from-file=certs/consul-key.pem


echo "Storing the Consul config in a ConfigMap..."

kubectl -n vault create configmap consul --from-file=consul/config.json


echo "Creating the Consul Service..."

kubectl -n vault create -f consul/service.yaml


echo "Creating the Consul StatefulSet..."

kubectl -n vault create -f consul/statefulset.yaml


echo "Creating a Secret to store the Vault TLS certificates..."

kubectl -n vault create secret generic vault \
    --from-file=certs/ca.pem \
    --from-file=certs/vault.pem \
    --from-file=certs/vault-key.pem


echo "Storing the Vault config in a ConfigMap..."

kubectl -n vault create configmap vault --from-file=vault/config.json


echo "Creating the Vault Service..."

kubectl -n vault create -f vault/service.yaml


echo "Creating the Vault Deployment..."

kubectl -n vault apply -f vault/deployment.yaml


echo "All done! Forwarding port 8200..."

POD=$(kubectl -n vault get pods -o=name | grep vault | sed "s/^.\{4\}//")

while true; do
  STATUS=$(kubectl -n vault get pods ${POD} -o jsonpath="{.status.phase}")
  if [ "$STATUS" == "Running" ]; then
    break
  else
    echo "Pod status is: ${STATUS}"
    sleep 5
  fi
done

kubectl -n vault port-forward $POD 8200:8200
