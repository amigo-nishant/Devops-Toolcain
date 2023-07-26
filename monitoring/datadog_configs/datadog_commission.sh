#!/bin/bash
rm -rf datadog-agent-temp.yaml
kubectl apply -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/clusterrole.yaml" -n $3
kubectl apply -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/serviceaccount.yaml" -n $3
kubectl apply -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/clusterrolebinding.yaml" -n $3
cat datadog-agent.yaml | sed "s/API-KEY/$1/g; s/TOKEN-ID/$2/g; s/KUBE-NAMESPACE/$3/g;" | cat - >> datadog-agent-temp.yaml
kubectl apply -f datadog-agent-temp.yaml 
