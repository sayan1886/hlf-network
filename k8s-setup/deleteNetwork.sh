# Set environment variables

source ./env.sh

# Delete TLS CA Server
echo Deleting tls root ca deployment
kubectl delete -f tls-ca/tls-ca.yaml
echo Waiting until all pods are terminated
kubectl wait --for=delete pod -l app=ca-tls-root --timeout=60s

# Delete ORDERER ORG CA Server
echo Deleting rca-org0 root ca deployment
kubectl delete -f orderer-org-ca/orderer-org-ca.yaml
echo Waiting until all pods are terminated
kubectl wait --for=delete pod -l app=rca-org0-root --timeout=60s

# Delete ORG1 CA Server
echo Deleting rca-org0 root ca deployment
kubectl delete -f org1-ca/org1-ca.yaml
echo Waiting until all pods are terminated
kubectl wait --for=delete pod -l app=rca-org1-root --timeout=60s

# Delete ORG2 CA Server
echo Deleting rca-org0 root ca deployment
kubectl delete -f org2-ca/org2-ca.yaml
echo Waiting until all pods are terminated
kubectl wait --for=delete pod -l app=rca-org2-root --timeout=60s

# Delete TLS CA Service
echo Deleting tls root ca service
kubectl delete -f tls-ca/tls-ca-service.yaml

# Delete ORDERER ORG CA Service
echo Deleting rca-org0 root ca service
kubectl delete -f orderer-org-ca/orderer-org-ca-service.yaml

# Delete ORG1 CA Service
echo Deleting rca-org1 root ca service
kubectl delete -f org1-ca/org1-ca-service.yaml

# Delete ORG2 CA Service
echo Deleting rca-org2 root ca service
kubectl delete -f org2-ca/org2-ca-service.yaml

# Remove tmp dir
echo Deleting tmp directory
rm -rf $TMP_FOLDER
