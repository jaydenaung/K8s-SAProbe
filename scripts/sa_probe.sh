#!/bin/bash
NAMESPACE=default
pos=$(kubectl get pods | awk ' NR = 3 {print $1}' | sed 1d)
PODWITHTOKEN=0
echo "This script will scan if any service account mounted on any of the pods has access to any Kubernetes secrets..."
for po in $pos
do
export sa=$(kubectl exec -it $po -- mount | grep serviceaccount | cut -d" " -f 3)
  if [[ $sa != "/run/secrets/kubernetes.io/serviceaccount" ]]
    then
    echo "Service Account is not mounted on this Pod $po!"
  else 
    echo "POD $po has service account mounted here: $sa.."
    PODWITHTOKEN=$(( PODWITHTOKEN + 1 ))
    echo "PROBING SERVICE ACCOUNT TOKEN.."
    echo "POD $po has a SERVICE ACCOUNT TOKEN.."
    TOKEN=$(kubectl exec -it $po -- cat /run/secrets/kubernetes.io/serviceaccount/token)
    echo "......."
    echo "Probing to see whether this service account has access to any Kubernetes SECRETS in $NAMESPACE namespace.."
    echo "HERE YOU GO.."
    kubectl exec -it $po -- curl -k -H "Authorization: Bearer $TOKEN" \
    -H 'Accept: application/json' \
    https://kubernetes/api/v1/namespaces/$NAMESPACE/secrets/ 
    sleep 1
    echo "Probing to see whether this service account has access to any Kubernetes CONFIGMAPS in $NAMESPACE namespace.."
    echo "HERE YOU GO.."
    kubectl exec -it $po -- curl -k -H "Authorization: Bearer $TOKEN"  https://kubernetes/api/v1/namespaces/$NAMESPACE/configmaps/
  fi
sleep 1
done
echo "You have $PODWITHTOKEN Pods that have Service Account mounted."


