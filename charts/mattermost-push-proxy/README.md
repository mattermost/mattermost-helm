Mattermost Push Proxy Helm Chart
====================================================

This is the Helm chart for the Mattermost Push Proxy Notification service. It is used at Mattermost internally by our [community.mattermost.com](https://community.mattermost.com) server to push notifications to iOS and Android devices. To learn more about Helm charts, [see the Helm docs](https://helm.sh/docs/). You can find more information about Mattermost Push Proxy setup [here](https://developers.mattermost.com/contribute/mobile/push-notifications/service/).

A Mattermost hosted Push Notification service is offered and more details can be found [here](https://docs.mattermost.com/mobile/mobile-hpns.html).

The push proxy source code lives [here](https://github.com/mattermost/mattermost-push-proxy).

# Install

```bash
helm repo add mattermost https://helm.mattermost.com
```

Install a version of the preferred chart by running:

```bash
helm install mm-push-proxy mattermost/mattermost-push-proxy --namespace mm-push-proxy --create-namespace
```

To upgrade an existing release, modify the `config.yaml` with your desired changes and then use:
```bash
helm upgrade -f values.yaml <your-release-name> mattermost/mattermost-push-proxy
```

## Required Settings

At minimum these are the settings you need to update:

* `applePushSettings` - set this section to be able to get notifications in iOS devices.
* `androidPushSettings` - set this section to be able to get notifications in Android devices.


## Ingress

If you are using nginx-ingress, set the following:

```yaml
ingress:
  enabled: true
  hosts:
    - push-proxy.example.com
```

where `push-proxy.example.com` is your domain name and the url you will specify in your Mattermost Server as push-proxy target.

### HTTPS

To run with HTTPS, add an SSL/TLS certificate as a secret to your Kubernetes cluster, either manually or [using cert-manager](#certificate-manager).

Set the following to enable HTTPS:

```yaml
ingress:
  enabled: true
  hosts:
    - push-proxy.example.com
  tls:
    - secretName: your-tls-secret-name
      hosts:
        - push-proxy.example.com
```

### DNS

To route users from your domain name to your Mattermost Push Proxy installation, point your domain name at the external IP or domain that your ingress exposes.

Depending on the DNS service and Ingress you're using, the steps can vary. If you are using nginx-ingress, you would do something like this:

1. Run `kubectl describe svc your-nginx-ingress-controller`
    * Replace `your-nginx-ingress-controller` with the name of your ingress controller service
2. Copy the domain name beside `LoadBalancer Ingress:`
3. On your DNS service, create a CNAME record pointing from the domain you'd like to use to the domain name you just copied
4. Save, and wait 10-15 minutes for the DNS change to propagate

## Uninstalling Mattermost Push Proxy Helm Chart

If you are done with your deployment and want to delete it, use `helm delete <your-release-name>`. If you don't know the name of your release, use `helm ls` to find it.


# Developing

If you are going to modify the helm charts, it is helpful to use `--dry-run` (doesn't do an actual deployment) and `--debug` (print the generated config files) when running `helm install`.

Helm has partial support for pulling values out of a subchart via the requirements.yaml. It also has limited support for pushing values into subcharts. It does not support using templating inside a values.yaml file.

We recommend using [kind](https://github.com/kubernetes-sigs/kind) for local development if you do not have access to Kubernetes cluster running in the cloud.
