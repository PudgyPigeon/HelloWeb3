# Deplyoment and Access Instructions

This repository contains easily reproducable steps to provision
a GKE cluster along with the necessary Dockerfiles, monitoring, networking,
and DNS services set up.

However, you may need to customize a couple of values in order to port this
deployment over into a completely new GCP account/VPC.

## Deployment Instructions

### GCP Project Setup
It is assumed that the user has already signed up for GCP and availed themselves of the services
and APIs needed for the rest of the instructions.

Please make sure to create these resources and keep track of the names and IDs for the next step:
- Create a Project and write down the project ID.
- Create a Google Storage Bucket and note down the unique name of this resource.
- Go to polygonscan.com and obtain an API key from a free account. 
- Obtain a domain/DNS name such as example.com from Google Cloud.
    - Create two subdomains for this domain. 
        - One domain for the HelloWeb3 Service
        - One domain for the Grafana Service
- Keep note of the email you used to sign up for the domain name and Google Project. This will
be needed for the cluster issuer.

### Terraform Setup For GKE
This terraform directory: `./terraform` contains the necessary infrastructure as code
to set up the baseline scaffolding for the GKE cluster and VPC. It also handles the 
provisioning of Prometheus, Grafana, NGINX Ingress Controller, and various namespace
and Kubernetes Secrets.

1.) Make sure to install the Google Cloud SDK onto your machine and authenticate via CLI
to the cloud project you wish to deploy to.
2.) Download and install Kubectl and Helm.
3.) Install the Terraform CLI tool.
2.) To deploy this stack to your Google Cloud Project, please replace the various exported
variables defined within the script at this location with the values derived from
the previous step:

```
# ./scripts/deploy_gke.sh

export TF_VAR_project_id="helloweb3-439906"
export TF_VAR_region="us-central1"
export TF_VAR_bucket="helloweb3-terraform-bucket"
export TF_VAR_gke_cluster_name="gke-cluster-1"
export TF_VAR_grafana_admin_user="admin"
export TF_VAR_grafana_admin_password="adminPassword"
export TF_VAR_polygon_api_key="" # Add your Polygon API key here
export TF_VAR_cluster_issuer_email="" # cluster issuer email
```

4.) Run the command `./scripts/deploy_gke.sh`

### Node.js Application
In order to deploy this Node.js application, the end user must first create a Google
Artifact Registry resource and replace the Github Actions Repository Variables that reference it.

Once this is done, triggering the Github Actions workflow via a manual workflow dispatch, or a tagging
action (Pushing the tag via CLI or other console tools), will automatically trigger the build
process and push the resultant image into Artifact Registry where it can be used by the 
proceeding Helm deployment.

### Helm Deployment - HelloWeb3
If you have successfully pushed the image and created the cluster, then the next step is to configure
your Kubectl CLI tool via Kubeconfig.

Configure cluster access by running the following command:
```
gcloud components install gke-gcloud-auth-plugin

gcloud container clusters get-credentials CLUSTER_NAME \
    --region=COMPUTE_REGION
```

In this examle, replace CLUSTER_NAME with `gke-cluster-1` and COMPUTE_REGION with `us-central1`.

Now you should be able to run Helm and install the Helm charts held within `helm/helloWeb3`.

If users wish to customize the deployment, they may change the values in `helm/helloWeb3/values.yaml`.
Thing such as host names, port numbers, and API Key names are all configurable.

To manually do so, run the following command:
```
helm upgrade --install helloweb3 ./helm/helloWeb3 \
--namespace helloweb3 \
--set image.repository=${{ FULL_REPOSITORY_URL }} \
--set image.tag=:$TAG
```

However, users are able to run this via Github Actions and it will deploy to a previously configured
cluster.

### Ingress and DNS
Now that you have deployed the GKE cluster and the Helm deployment, you must set up the DNS routing
in Google Cloud in order to make the Ingress resources functional and expose the services to the
external internet.

If more time were allowed, fully automatic processes to deal with this could be set up.

For now, we will go the the Hosted Zones section of Google cloud.

Run the following commands:
```
kubectl get ing -A
```

You should be returned values such as this:
```
NAMESPACE    NAME        CLASS   HOSTS                                                                     ADDRESS        PORTS     AGE
helloweb3    helloweb3   nginx   *.app.randomdnsnamerighthere.com,app.randomdnsnamerighthere.com           34.57.136.50   80, 443   3h50m
monitoring   grafana     nginx   *.grafana.randomdnsnamerighthere.com,grafana.randomdnsnamerighthere.com   34.57.136.50   80, 443   94m
```

In order to make the DNS functional, create A records within your DNS hosted zone, and point the address to the IP Address (34.57.136.50)
to the A record you are creating at the host name on the same row.

For example, your A record must have a domain name of `app.randomdns....com` and point this to `34.57.136.50` within the web console. 
Click create record and wait approximately 10-20 minutes. 

Once that is done, the Certificate manager you deployed in the Terraform cluster and Helm charts should automatically set up HTTPS/SSL
traffic.

### Prometheus and Grafana
Deploying these resources have been handled in the Terraform step.

## Accessing resources
In order to access the URL for the services, use the same command as in the Ingress step:
```
kubectl get ing -A
```
```
NAMESPACE    NAME        CLASS   HOSTS                                                                     ADDRESS        PORTS     AGE
helloweb3    helloweb3   nginx   *.app.randomdnsnamerighthere.com,app.randomdnsnamerighthere.com           34.57.136.50   80, 443   3h50m
monitoring   grafana     nginx   *.grafana.randomdnsnamerighthere.com,grafana.randomdnsnamerighthere.com   34.57.136.50   80, 443   94m
```

In this example, using `app.randomdnsnamerighthere.com/` will bring you to the home page of the HelloWeb3 service.
To access the metrics endpoint `app.randomdnsnamerighthere.com/metrics` should suffice.

And in order to access Grafana, simply go to `grafana.randomdnsnamerighthere.com`.

In the login page, use the following credentials to login:
Username: admin
Password: adminPassword

Note that these are just defaults and can be changed within the `deploy_gke.sh` script or `variables.tf` file of the Terraform configuration.

## Dashboard
To view the Grafana dashboard, head to this link `https://grafana.randomdnsnamerighthere.com/dashboards` or simply
use the left-hand sidebar in the Grafana endpoint to view the Kubernetes Overview.

It will show general cluster metrics as well as some visualizations for the HelloWeb3 service.

If more time were allowed, custom scraper configs for the Prometheus service could be configured.