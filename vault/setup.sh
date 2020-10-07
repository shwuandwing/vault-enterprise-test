#!/bin/bash

docker-compose stop
pushd ./transit-vault
rm -rf .terraform/
rm -rf terraform.tfstate
rm -rf terraform.tfstate.backup
popd
pushd ./vault
rm -rf .terraform/
rm -rf terraform.tfstate
rm -rf terraform.tfstate.backup
popd

echo "Start docker-compose on vault_transit"

docker-compose up --no-start
docker-compose start vault_transit
pushd ./transit-vault
terraform init
terraform apply -auto-approve
popd

echo "Start docker-compose on vault cluster"
docker-compose start consul
docker-compose start statsd
docker-compose start vault_1
docker-compose start vault_2
docker-compose start vault_3
RESPONSE=$(vault operator init -recovery-shares=1 -recovery-threshold=1 -format=json)
echo $RESPONSE
ROOT_TOKEN=$(echo $RESPONSE | jq -j .root_token)
echo ROOT TOKEN = $ROOT_TOKEN
export VAULT_TOKEN=$ROOT_TOKEN
pushd ./vault
terraform init
terraform apply -auto-approve
popd
vault login -address=http://127.0.0.1:8200 -method=userpass username=user password=password
echo "Setup done"

sleep 5
docker-compose logs -f