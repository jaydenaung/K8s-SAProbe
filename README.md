# Kubernetes Probes

Just a repo to share some useful scripts I've used in probing Kubernetes. I'll keep updating this repo as I come across new use cases.

## Pre-requisites
- The bash scripts will use Kubernetes CLI such as "kubectl". ( Download `kubectl` [here](https://kubernetes.io/docs/tasks/tools/))

## Scripts 

1. [sa_secrets_probe.sh](scripts/sa_secrets_probe.sh). - A script to probe Kubernetes secrets using "Service Accounts" mounted on each pod in a namespace. This will allow you to know whether any excessive role that can have access to secrets is being bound to service account that is used by the pods in a namespace. 

> This will only work if the linux Pod are have `curl` installed.

### How to 

- In the script, update the $NAMESPACE variable according to your requirement. 

```bash
NAMESPACE=default
```

- Execute the script

```bash
./sa_secrets_probe.sh
```


