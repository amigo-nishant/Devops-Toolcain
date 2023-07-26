Helm chart name: redis
Helm remote repository: https://charts.bitnami.com/bitnami
Command to clone only the redis chart locally

Add the remote repository to the list
helm repo add bitnami https://charts.bitnami.com/bitnami

Search for the redis chart inside the list of repository to know the version of chart and app
helm search repo redis

Pull the chart named redis from the list, extract it into an directory
helm pull bitnami/redis --untar --untardir charts


Helm command to run the redis ( 1 master and multiple slave architecture) deployment
helm upgrade --install <deployment_name> <chart_directory> --vaules=values.yaml --namespace=dev
The above deployment brings up 3 pods (1 master and 2 replicas) along with sentinel process on it.
Sentinel: It is a redis process which monitors the redis instances, supports notification and performs the failover when master instances fails. It conduct the election among the slaves to promote 1 instance to master and parellel it brings up new pod to adjust the slave quota.
The above Redis helm chart bring up 3 pods ( with redis and sentinel containers) with the 5GB of persistent storage attached to it. Both redis and sentinel containers has been exposed with the single service on port 6379 and 26379 respectively.
We will have a one more service created which can be used internally in the cluster as it would not have Ip address to expose it to outer network.
local domain: <deployment_name>-headless..svc.cluster.local
EX: Suppose we have a slave node named redis-0 then following will be the local DNS which will be accessible inside the cluster.
redis-0.<deployment_name>-headless..svc.cluster.local
To know at point in time who is the master among all these pods, we can check the logs of any sentinel container inside the pod which will give infomation about the master.
Main configuraton in values.yaml

architecture = replication (single master and multiple slaves)
redis image.tag  =  7.0.12 (latest stable version)
auth.enable = true ( enable auth for redis)
auth.sentinel = true (enable auth to sentinel)
Master count = 1
Replicas count = 3 ( 3 redis pods with 1 master in it)
Replicas persistent storage = 5Gi
Replica service type = ClusterIP (only accessible inside the cluster)
master and replica updateStrategy = RollingUpdate
sentinel.enable = true ( which adds sentinel container in all the pods to monitor)
sentinel image.tag = 7.0.11 (latest)

Reference link: https://github.com/bitnami/charts/tree/main/bitnami/redis