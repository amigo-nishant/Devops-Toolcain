#!/bin/bash
kubectl delete daemonset datadog -n $1 
kubectl delete deployment datadog-cluster-agent -n $1
kubectl delete svc datadog-cluster-agent -n $1
kubectl delete svc datadog-cluster-agent-admission-controller -n $1
