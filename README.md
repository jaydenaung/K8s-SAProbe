# Kubernetes Security Scripts

Just a repo to share some useful scripts I've used in Kubernetes security labs. You can use Kubernetes CLI to achieve the same result manually and repeatedly for each and every pods but why not automate it, right? I'll keep adding new scripts to this repo whenever I come across new use cases.

## Pre-requisites
- The bash scripts will use Kubernetes CLI such as **kubectl**. ( Download `kubectl` [here](https://kubernetes.io/docs/tasks/tools/))

- The Kubernetes user does not need to have access to Secrets and ConfigMaps. But the user needs to be able to `exec` into pods. 

# Scripts 

## Secrets Probe (Using Service Accounts in Pods) 

Have you ever wondered, in a Kubernetes cluster, if the "service accounts" that are being mounted on the pods have access to "Secrets" stored in un-encrypted etcd database, and ConfigMaps (and they shouldn't)? Sometimes your Kubernetes user's permission may be configured according to least-privilege principle, but that might not be the case for some service accounts. Sometimes such service accounts were created "Not Accidentally".

This is a script to probe Kubernetes Secrets and ConfigMaps using the permission of "Service Accounts" mounted on each pod in a namespace. This will allow you to know whether any excessive role that can have access to Secrets and ConfigMaps is being bound to service account that is used by the pods in a namespace. Download the script here - [sa_probe.sh](scripts/sa_probe.sh).

> Note: This will only work on the linux Pods which have `curl` installed.

### How to 

- In the script, update the $NAMESPACE variable according to your requirement. The default is `default` namespace. 

```bash
NAMESPACE=default
```

- Execute the script

```bash
./sa_secrets_probe.sh
```

### Expected Result

You will probably see a rather lengthy report because the probe ran against each and every pod it can find. It will return all Secrets, ConfigMaps discovered using the permission of service accounts mounted on pods in a namespace. 

If you scroll through it, you might probably find secrets stored in un-encrypted `etcd` database like the one below:

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

This probe script is designed to find both **Secrets** and **ConfigMaps**. And if you see the script discover and expose secrets when it shouldn't, that means you have excessive permission issues with the roles that are attached to service accounts! Time to tighten RBAC and encrypt `etcd`!


