#!/bin/bash

source "/tmp/hyperledger/scripts/util.sh"

set -e

log "Use CA-client to enroll admin"

export TLS_CA_HOST=0.0.0.0:7052
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/ca-client/
mkdir -p $FABRIC_CA_CLIENT_HOME

fabric-ca-client enroll -u https://tls-ca-admin:tls-ca-adminpw@$TLS_CA_HOST

log "Use CA-client to register initial identities"

fabric-ca-client register --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://$TLS_CA_HOST
fabric-ca-client register --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://$TLS_CA_HOST
fabric-ca-client register --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://$TLS_CA_HOST
fabric-ca-client register --id.name peer2-org2 --id.secret peer2PW --id.type peer -u https://$TLS_CA_HOST
fabric-ca-client register --id.name orderer-org0 --id.secret ordererPW --id.type orderer -u https://$TLS_CA_HOST

log "Finished registering TLS users"
