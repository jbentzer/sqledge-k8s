# sqledge-k8s

Deployments for SQL Edge on Kubernetes.

## YAML

Change setting in the YAML and apply with:

    kubectl apply -f azure-sqledge.yaml --namespace mssql

## JSONNET

Install with:

    kubecfg create -f azure-sqledge.jsonnet --namespace mssql

## Helm

Install with:

    helm upgrade --install sqledge azuresqledge/sqledge --namespace mssql
