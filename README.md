# Kubernetes Probes

Just a repo to share some useful scripts I've used in Kubernetes security labs. You can use Kubernetes CLI to achieve the same result manually and repeatedly for each and every pods but why not automate it, right? I'll keep adding new scripts to this repo whenever I come across new use cases.

## Pre-requisites
- The bash scripts will use Kubernetes CLI such as "kubectl". ( Download `kubectl` [here](https://kubernetes.io/docs/tasks/tools/))

# Scripts 

## Secrets Probe (Using Service Accounts in Pods) 

Download the script here - [sa_secrets_probe.sh](scripts/sa_secrets_probe.sh). This is a script to probe Kubernetes secrets using "Service Accounts" mounted on each pod in a namespace. This will allow you to know whether any excessive role that can have access to secrets is being bound to service account that is used by the pods in a namespace. 

> Note: This will only work on the linux Pods which have `curl` installed.

### How to 

- In the script, update the $NAMESPACE variable according to your requirement. 

```bash
NAMESPACE=default
```

- Execute the script

```bash
./sa_secrets_probe.sh
```

### Expected Result

You will see a rather lengthy result because the probe ran against each and every pod it can find.

You might probably find secrets stored in un-encrypted `etcd` database like the one below:

```bash

    {
      "metadata": {
        "name": "mysecret",
        "namespace": "default",
        "selfLink": "/api/v1/namespaces/default/secrets/mysecret",
        "uid": "fc921e0e-4c0f-4709-b560-a2f8b8c83641",
        "resourceVersion": "2551267",
        "creationTimestamp": "2021-08-01T12:12:09Z",
        "managedFields": [
          {
            "manager": "kubectl",
            "operation": "Update",
            "apiVersion": "v1",
            "time": "2021-08-01T12:12:09Z",
            "fieldsType": "FieldsV1",
            "fieldsV1": {"f:data":{".":{},"f:password":{},"f:username":{}},"f:type":{}}
          }
        ]
      },
      "data": {
        "password": "UEBzc3cwcmQ=",
        "username": "Z3Jvb3Q="
      },
      "type": "Opaque"
    },


```

You can grab the secret value which is encoded. And you can do the following and get the base64 decoded value

```bash
echo UEBzc3cwcmQ= | base64 -d
P@ssw0rd
```

> Note: ALWAYS encrypt your `etcd` to avoid exposure like this!

And if you see the probe script discover and expose secrets when it shouldn't, that means you have excessive permission issues with the roles that are attached to service accounts! Time to tighten RBAC and encrypt `etcd`!


