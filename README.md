Mattermost Kubernetes 
==========================

# This is an experimental work in progress

How to setup on your OSX developer machine 
-----------------------------------------

Install kubectrl with brew
```bash
brew install kubectl
kubectl version
```
Install minikube with the directions at https://kubernetes.io/docs/getting-started-guides/minikube/

Make sure minikube is running or start it with the following command
```bash
minikube start
```

Checkout the minikube dashboard with the following command
```bash
minikube dashboard
```

To setup a Mattermost HA cluster for testing with the latest build from master run the following command.
```bash
./setup.sh
```

If you're running in minikube you can open all the appropriate browsers windows to the running services using the following command.  This should open grafana with username=`admin` and password=`admin` and the Mattermost cluster where you can create your own system admin account.
```bash
./where.sh
```

If you want to start from a clean state you can run the following command to reset back to where you can run setup.sh again.
```bash
./cleanup.sh
```

When in doubt you can run the nuke command to cleanup your local environment and all downloaded content.
```bash
./nuke.sh
```

If you wish to run the load test then execute the following commands
```bash
cd load-test
./run-setup.sh
```

If you want to stop the load tests then run the following commands
```bash
cd load-test
./run-cleanup.sh nuke
```