source ./util.sh

header "Starting Peers"

echo "org1-peer1"
kubectl create -f "$K8S/org1-peer1/org1-peer1.yaml" -n hlf-production-network
kubectl create -f "$K8S/org1-peer1/org1-peer1-service.yaml" -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=peer1-org1 --timeout=120s -n hlf-production-network

sep

echo "org1-peer2"
kubectl create -f "$K8S/org1-peer2/org1-peer2.yaml" -n hlf-production-network
kubectl create -f "$K8S/org1-peer2/org1-peer2-service.yaml" -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=peer2-org1 --timeout=120s -n hlf-production-network



sep

echo "org2-peer1"
kubectl create -f "$K8S/org2-peer1/org2-peer1.yaml" -n hlf-production-network
kubectl create -f "$K8S/org2-peer1/org2-peer1-service.yaml" -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=peer1-org2 --timeout=120s -n hlf-production-network



sep

echo "org2-peer2"
kubectl create -f "$K8S/org2-peer2/org2-peer2.yaml" -n hlf-production-network
kubectl create -f "$K8S/org2-peer2/org2-peer2-service.yaml" -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=peer2-org2 --timeout=120s -n hlf-production-network