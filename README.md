Mattermost Kubernetes
==========================

This helm chart is still under construction.

# Configuration

To start, copy [mattermost-helm/values.yaml](https://github.com/mattermost/mattermost-kubernetes/blob/master/mattermost-helm/values.yaml) and name it `config.yaml`. This will be your configuration file for the Mattermost helm chart.

## DNS

Depending on the DNS service you're using, the exact steps will differ but generally to point your domain name at your release you can do the following:

Note that your helm release must already be installed and running.

1. Run `kubectl describe svc <release-name>-nginx-ingress-controller`
2. Copy the domain name beside "LoadBalancer Ingress:"
3. On your DNS service, create a CNAME record pointing from the domain you'd like to use to the domain name you just copied
4. Save that and wait 10-15 minutes for the DNS change to propagate

## TLS/SSL

To configure the chart to use Let's Encrypt to register and get a TLS certificate, do the following:

* Set `tls.enabled` to `true`
* Set `tls.hostname` to the domain name that will be hosting your Mattermost instance
* Set `kube-lego.LEGO_EMAIL` to the email to use when registering the TLS certifcate

Note that at first, we're using the staging Let's Encrypt URL. We suggest doing this so that if there is an error, you don't get rate limited by Let's Encrypt.

Now, install or upgrade your helm release, wait a couple minutes and go to your domain. You should see an invalid TLS certificate. That certificate should be named "Fake LE Intermediate X1". If it is, then it worked.

After it's working in the staging environment, we need to do a few things to switch it over to production:

* Set `kube-lego.LEGO_URL` to `https://acme-v01.api.letsencrypt.org/directory`
* Delete the existing kube-lego secret with `kubectl delete secret kube-lego-account`
* Delete the staging tls cert with `kubectl delete secret <release-name>-mattermost-tls-cert`

Now, just install or upgrade your helm release, wait a couple minutes and you should have a valid TLS certificate working at your domain.

# Install

```
helm repo add mattermost https://releases.mattermost.com/helm
helm upgrade -f config.yaml mattermost-helm
```

# Getting started using minikube

## Install minikube and kubectl

See: https://kubernetes.io/docs/tasks/tools/install-minikube/

## Launch minikube

The helm charts start a lot of containers, and it will work better if you 
launch minikube with additional memory and CPU. You also need to enable 
persistent volume mapping. This only needs to be done the first time you launch
minikube. The settings will persist across restarts. If you need to modify the
values try `minikube delete` and `minikube stop`

```bash
minikube start --memory 4096 --cpus 4 --mount
```

## Install and start Helm

See: https://docs.helm.sh/using_helm/#quickstart

Once helm is installed, run `helm init` to get it loaded onto minikube

You may need to add some additional repos for helm

```bash
helm repo add mattermost https://releases.mattermost.com/helm
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```

## Launch Mattermost

The helm charts have external dependencies, fetch them with:

```bash
helm dependency update
```

Once dependencies have been loaded, you can launch the charts directly with:
```bash
helm install ./mattermost-helm
```

If you have a custom config you would like to use (say a license key), create a `config.yaml` 

To list options for mattermost-helm:

```bash
helm inspect values mattermost-helm
```

Create a yaml file `config.yaml` to overide any defaults you want to change and
install using:

```bash
helm install -f config.yaml ./mattermost-helm
```

## Tearing down your Mattermost deployment

If you are done with your deployment and want to delete it, you can use 
`helm delete <NAME>` where <NAME> is the name of your deployment. If you don't
know the name of your deployment, you can use `helm ls` to find it.

You may also want/need to delete the persistent volumes from minikube. To do 
that use `kubectl get pv,pvc` to get a list of persistent volumes and claims, 
and use `kubectl delete` to delete them.

## Developing the helm charts

If you are going to modify the helm charts, it is helpful to use `--dry-run`
(doesn't do an actual deployment) and `--debug` (print the generated config
files) when running `helm install`.

Helm has partial support for pulling values out of a subchart via the 
requirements.yaml. It also has limited support for pushing values into 
subcharts. It does not support using templating inside a values.yaml file.
