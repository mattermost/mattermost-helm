# mattermost-elasticsearch

Based on https://github.com/pires/kubernetes-elasticsearch-cluster and https://github.com/clockworksoul/helm-elasticsearch.

### Important Notes

* When changing `replicas` count for `master` pods make sure you also update `requiredMasters`. If there are less replicas than required, the elasticsearch cluster will not elect a leader and you will get "MasterNotDiscoveredException" errors in your client pod logs. Kubernetes may report the pod as RUNNING in this case, even though it is failing.
* Depending on your platform (AWS, etc.) you may need to change `networkHost`. See https://github.com/pires/kubernetes-elasticsearch-cluster#no-up-and-running-site-local for more information.
