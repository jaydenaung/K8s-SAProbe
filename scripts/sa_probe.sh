#!/bin/bash
#########################################################################################################################
#                                                                                                                       #
#                                                                                                                       #
#   SAProbe - a tool that discovers Kubernetes Secrets and ConfigMaps that are exposed via powerful Service Accounts.   #
#                                                                                                                       #
#                                                                                                                       #
#########################################################################################################################
#                                                                                                                       #
#                                                                                                                       #
#                                  Author: Jayden Kyaw Htet Aung (Twitter: @JaydenAung)                                 #
#                                  LinkedIn: https://www.linkedin.com/in/jaydenaung/                                    #
#                                                                                                                       #
#                                                                                                                       #
#                                                                                                                       #
#########################################################################################################################
# Version - 1.1

# Version Notes:
#
# version: 1.0 - 30-08-2021 - Inital script.
# version 1.1 - 03-09-2021 - Added printing of "Service Account" in each pod.
# Author's note: This is my personal, weekend project. All development work in this tool is not in any way related to my employer. 

# SAProbe
# Update the NAMESPACE accordingly
NAMESPACE=default

SAProbever=1.1
pos=$(kubectl get pods | awk ' NR = 3 {print $1}' | sed 1d)
PODWITHTOKEN=0
echo "SAProbe version \"$SAProbever\"."
echo "This script will find out if any service account mounted on any of the pods has access to any Kubernetes secrets..."

for po in $pos
do
  export sa=$(kubectl exec -it $po -- mount | grep serviceaccount | cut -d" " -f 3)
  if [[ $sa != "/run/secrets/kubernetes.io/serviceaccount" ]]
    then
    echo "Service Account is not mounted on this Pod \"$po\"!"
  else 
    echo "POD \"$po\" has service account mounted here: \"$sa\".."
    PODWITHTOKEN=$(( PODWITHTOKEN + 1 ))
    echo "PROBING SERVICE ACCOUNT TOKEN.."
    echo "POD \"$po\" has a SERVICE ACCOUNT TOKEN.."
    TOKEN=$(kubectl exec -it $po -- cat /run/secrets/kubernetes.io/serviceaccount/token)
    echo "......."
    echo "Probing to see whether this service account has access to any Kubernetes SECRETS in \"$NAMESPACE\" namespace.."
    echo "HERE YOU GO.."
    kubectl exec -it $po -- curl -k -H "Authorization: Bearer $TOKEN" \
    -H 'Accept: application/json' \
    https://kubernetes/api/v1/namespaces/$NAMESPACE/secrets/ 
    sleep 1
    echo "Probing to see whether this service account has access to any Kubernetes CONFIGMAPS in \"$NAMESPACE\" namespace.."
    echo "HERE YOU GO.."
    kubectl exec -it $po -- curl -k -H "Authorization: Bearer $TOKEN" \
    -H 'Accept: application/json' \
    https://kubernetes/api/v1/namespaces/$NAMESPACE/configmaps/
  fi
sleep 1
done
echo "Probe has finished discovering exposed Secrets and ConfigMaps."

echo "You have $PODWITHTOKEN Pods that have Service Account mounted."
for po in $pos
do
  svcacc=$(kubectl get po $po -oyaml | grep serviceAccountName | awk ' { print $2 } ')
  echo "The service account mounted on Pod \"$po\" is \"$svcacc\""
  sleep 1
done




