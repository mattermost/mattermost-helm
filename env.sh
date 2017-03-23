#!/bin/bash

# This is some general enviroment properties we use in the various scripts

export USING_MINIKUBE=false
export MINIKUBE_STATUS=false
export MM_BUILD=master

echo "Initializing enviroment"

if hash minikube 2>/dev/null; then
    MINIKUBE_STATUS=$(minikube status | grep -c "minikubeVM: Running")
	if [ "$MINIKUBE_STATUS" == "1" ]; then
		echo "minikube is installed, running docker enviroment cmd"
    	eval $(minikube docker-env)
    	USING_MINIKUBE=true
    else
    	echo "minikube is installed but isn't running."
	fi
else
    echo "minikube is not installed.  Skipping env setup for minikube."
fi