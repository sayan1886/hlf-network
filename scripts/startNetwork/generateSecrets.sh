#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

generatePassword() {
  openssl rand -base64 64 | tr -dc A-Za-z0-9 | head -c 32 ; echo ''
}

TEST_MODE=""
while getopts 't' flag; do
  case "${flag}" in
    t) TEST_MODE="-t" ;;
    ?) printf 'Invalid flag!' ;;
  esac
done


header "Generation of Certificates and Credentials"

# Ensure lagom namespace exists
set +e
kubectl create namespace uc4-lagom
kubectl create namespace uc4-support
set -e

if [[ $TEST_MODE == "-t" ]]; then
  # Use for testing without lagom
  rm -rf /tmp/hyperledger/
  mkdir -p /tmp/hyperledger/
  mkdir -p /tmp/hyperledger/org0/msp/cacerts
  mkdir -p /tmp/hyperledger/org1/msp/cacerts
  mkdir -p /tmp/hyperledger/org2/msp/cacerts
fi

msg "Providing connection profile via secret for lagom"
kubectl create configmap connection-profile --from-file=assets/connection_profile_kubernetes.yaml -n uc4-lagom

small_sep


msg "Generating TLS CA root certificate and private key"
TMP_CERT=$(mktemp)
openssl ecparam -name prime256v1 -genkey -noout -out $TMP_CERT-key.pem
openssl req -new -key $TMP_CERT-key.pem -config assets/tls-ca-root-cert.cnf \
      -out $TMP_CERT.csr -subj "/C=DE/ST=NRW/L=Paderborn/O=UC4/OU=UC4/CN=tls-ca"
openssl x509 -req -days 730 -in $TMP_CERT.csr -signkey $TMP_CERT-key.pem \
      -out $TMP_CERT-cert.pem -extensions v3_req \
      -extfile assets/tls-ca-root-cert.cnf 2> /dev/null

msg "Providing certificate and private key as kubernetes secret"
kubectl create secret generic key.tls-ca -n hlf --from-file=key.pem=$TMP_CERT-key.pem
kubectl create secret generic cert.tls-ca -n hlf --from-file=cert.pem=$TMP_CERT-cert.pem
kubectl create secret generic cert.tls-ca -n uc4-lagom --from-file=cert.pem=$TMP_CERT-cert.pem
kubectl create secret generic cert.tls-ca -n uc4-support --from-file=cert.pem=$TMP_CERT-cert.pem

if [[ $TEST_MODE == "-t" ]]; then
  cp $TMP_CERT-cert.pem /tmp/hyperledger/ca-cert.pem
fi

msg "Generating credentials for tls ca"
kubectl create secret generic credentials.tls-ca -n hlf \
      --from-literal=username=admin \
      --from-literal=password=$(generatePassword)

small_sep


msg "Generating root certificate and private key for orderer organization"
TMP_CERT=$(mktemp)
openssl ecparam -name prime256v1 -genkey -noout -out $TMP_CERT-key.pem
openssl req -new -key $TMP_CERT-key.pem -config assets/rca-org0-cert.cnf \
      -out $TMP_CERT.csr -subj "/C=DE/ST=NRW/L=Paderborn/O=UC4/OU=UC4/CN=rca-org0"
openssl x509 -req -days 730  -in $TMP_CERT.csr -signkey $TMP_CERT-key.pem \
      -out $TMP_CERT-cert.pem -extensions v3_req \
      -extfile assets/rca-org0-cert.cnf 2> /dev/null

msg "Providing certificate and private key as kubernetes secret"
kubectl create secret generic key.rca-org0 -n hlf --from-file=key.pem=$TMP_CERT-key.pem
kubectl create secret generic cert.rca-org0 -n hlf --from-file=cert.pem=$TMP_CERT-cert.pem
kubectl create secret generic cert.rca-org0 -n uc4-lagom --from-file=cert.pem=$TMP_CERT-cert.pem
kubectl create secret generic cert.rca-org0 -n uc4-support --from-file=cert.pem=$TMP_CERT-cert.pem

if [[ $TEST_MODE == "-t" ]]; then
  cp $TMP_CERT-cert.pem /tmp/hyperledger/org0/msp/cacerts/org0-ca-cert.pem
fi

msg "Generating credentials for orderer organization"
kubectl create secret generic credentials.rca-org0 -n hlf \
      --from-literal=username=admin \
      --from-literal=password=$(generatePassword)

kubectl create secret generic credentials.tls.orderer-org0 -n hlf \
      --from-literal=username=orderer-org0 \
      --from-literal=password=$(generatePassword)

kubectl create secret generic credentials.orderer-org0 -n hlf \
      --from-literal=username=orderer-org0 \
      --from-literal=password=$(generatePassword)

kubectl create secret generic credentials.admin-org0 -n hlf \
      --from-literal=username=admin-org0 \
      --from-literal=password=$(generatePassword)

small_sep


msg "Generating root certificate and private key for organization 1"
TMP_CERT=$(mktemp)
openssl ecparam -name prime256v1 -genkey -noout -out $TMP_CERT-key.pem
openssl req -new -key $TMP_CERT-key.pem -config assets/rca-org1-cert.cnf \
      -out $TMP_CERT.csr -subj "/C=DE/ST=NRW/L=Paderborn/O=UC4/OU=UC4/CN=rca-org1"
openssl x509 -req -days 730 -in $TMP_CERT.csr -signkey $TMP_CERT-key.pem \
      -out $TMP_CERT-cert.pem -extensions v3_req \
      -extfile assets/rca-org1-cert.cnf 2> /dev/null

msg "Providing certificate and private key as kubernetes secret"
kubectl create secret generic key.rca-org1 -n hlf --from-file=key.pem=$TMP_CERT-key.pem
kubectl create secret generic cert.rca-org1 -n hlf --from-file=cert.pem=$TMP_CERT-cert.pem
kubectl create secret generic cert.rca-org1 -n uc4-lagom --from-file=cert.pem=$TMP_CERT-cert.pem
kubectl create secret generic cert.rca-org1 -n uc4-support --from-file=cert.pem=$TMP_CERT-cert.pem

if [[ $TEST_MODE == "-t" ]]; then
  cp $TMP_CERT-cert.pem /tmp/hyperledger/org1/msp/cacerts/org1-ca-cert.pem
fi

msg "Generating credentials for organization 1"
kubectl create secret generic credentials.rca-org1 -n hlf \
      --from-literal=username=admin \
      --from-literal=password=$(generatePassword)

kubectl create secret generic credentials.tls.peer1-org1 -n hlf \
      --from-literal=username=peer1-org1 \
      --from-literal=password=$(generatePassword)

kubectl create secret generic credentials.tls.peer2-org1 -n hlf \
      --from-literal=username=peer2-org1 \
      --from-literal=password=$(generatePassword)

kubectl create secret generic credentials.peer1-org1 -n hlf \
      --from-literal=username=peer1-org1 \
      --from-literal=password=$(generatePassword)

kubectl create secret generic credentials.peer2-org1 -n hlf \
      --from-literal=username=peer2-org1 \
      --from-literal=password=$(generatePassword)

kubectl create secret generic credentials.admin-org1 -n hlf \
      --from-literal=username=admin-org1 \
      --from-literal=password=$(generatePassword)

TMP_PASS=$(generatePassword)
kubectl create secret generic credentials.scala-admin-org1 -n hlf \
      --from-literal=username=scala-admin-org1 \
      --from-literal=password=$TMP_PASS

kubectl create secret generic credentials.scala-admin-org1 -n uc4-lagom \
      --from-literal=username=scala-admin-org1 \
      --from-literal=password=$TMP_PASS

TMP_PASS=$(generatePassword)
kubectl create secret generic credentials.scala-registration-admin-org1 -n hlf \
      --from-literal=username=scala-registration-admin-org1 \
      --from-literal=password=$TMP_PASS

kubectl create secret generic credentials.scala-registration-admin-org1 -n uc4-lagom \
      --from-literal=username=scala-registration-admin-org1 \
      --from-literal=password=$TMP_PASS

TMP_PASS=""

small_sep


msg "Generating root certificate and private key for organization 2"
TMP_CERT=$(mktemp)
openssl ecparam -name prime256v1 -genkey -noout -out $TMP_CERT-key.pem
openssl req -new -key $TMP_CERT-key.pem -config assets/rca-org2-cert.cnf \
      -out $TMP_CERT.csr -subj "/C=DE/ST=NRW/L=Paderborn/O=UC4/OU=UC4/CN=rca-org2"
openssl x509 -req -days 730 -in $TMP_CERT.csr -signkey $TMP_CERT-key.pem \
      -out $TMP_CERT-cert.pem -extensions v3_req \
      -extfile assets/rca-org2-cert.cnf 2> /dev/null

msg "Providing certificate and private key as kubernetes secret"
kubectl create secret generic key.rca-org2 -n hlf --from-file=key.pem=$TMP_CERT-key.pem
kubectl create secret generic cert.rca-org2 -n hlf --from-file=cert.pem=$TMP_CERT-cert.pem
kubectl create secret generic cert.rca-org2 -n uc4-lagom --from-file=cert.pem=$TMP_CERT-cert.pem
kubectl create secret generic cert.rca-org2 -n uc4-support --from-file=cert.pem=$TMP_CERT-cert.pem

if [[ $TEST_MODE == "-t" ]]; then
  cp $TMP_CERT-cert.pem /tmp/hyperledger/org2/msp/cacerts/org2-ca-cert.pem
fi

msg "Generating credentials for organization 2"
kubectl create secret generic credentials.rca-org2 -n hlf \
      --from-literal=username=admin \
      --from-literal=password=$(generatePassword)

kubectl create secret generic credentials.tls.peer1-org2 -n hlf \
      --from-literal=username=peer1-org2 \
      --from-literal=password=$(generatePassword)

kubectl create secret generic credentials.tls.peer2-org2 -n hlf \
      --from-literal=username=peer2-org2 \
      --from-literal=password=$(generatePassword)

kubectl create secret generic credentials.peer1-org2 -n hlf \
      --from-literal=username=peer1-org2 \
      --from-literal=password=$(generatePassword)

kubectl create secret generic credentials.peer2-org2 -n hlf \
      --from-literal=username=peer2-org2 \
      --from-literal=password=$(generatePassword)

kubectl create secret generic credentials.admin-org2 -n hlf \
      --from-literal=username=admin-org2 \
      --from-literal=password=$(generatePassword)
