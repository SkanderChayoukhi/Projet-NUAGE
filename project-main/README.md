# Table of Content

  * [Docker project](#docker-project)
  * [Kubernetes project](#kubernetes-project)
  * [Ansible project](#ansible-project)
  * [Terraform project](#terraform-project)

# Docker project

The goal of the project is to deploy the following application by using Docker and Docker compose. You will give us a GitHub or Gitlab link for your project.

![image](login-nuage-voting.drawio.svg)

## Mandatory version
- one Dockerfile per service that exposes the internal port of the container
- one docker-compose.yml file to deploy the stack
- adequate `depends_on`
- two networks will be defined: `front-net` and `back-net`
- a README file explaining how to configure and deploy the stack

## Optional extended version
- healthchecks on vote, redis and db services (some scripts are given in `healthcheck` directory)
- reducing the size of images
- multistage build on the worker service (.NET)


## Some elements

The base image will contain the basic tools for the language the application is written in.
You should use a tag to specify which version of the image you want to pull.
For building purposes, it is good practice to use a `slim` version of the image.



### `vote` service

This is a Python web server using the Flask framework. It presents a front-end for the user to submit their votes, then write them into the Redis key-value store.

For building the Dockerfile, before starting `app.py`:
- use the base image `python:3.11-slim`
- requirements have to be copied and installed in the container
- all necessary files and directories have to be copied in the container

Port mapping:
`5000` is used inside the container (see Python code). No port has to be exposed as the Nginx service is the entry point.

Healthcheck:


### `result` service

This is a Node.js web server. The front-end presents the results of the votes. The result values are taken from the PostgreSQL database.

Use the base image `node:18-slim`

In the Dockerfile, before running the code, make the working directory to `/usr/local/app` and
- copy package files into the container,
- install `nodemon` with `npm install -g nodemon`
- install more requirements:
```
npm ci
npm cache clean --force
mv /usr/local/app/node_modules /node_modules
```
- set the `PORT` environment variable

Finally, run the code with `node server.js`.


### `seed` service

This is a Python and bash program used to virtually send many vote requests to the `vote` server.

Use the base image `python:3.9-slim`

First the file `make-data.py` has to be executed in the container. Second, the file `generate-votes.sh` has to be executed when starting the container.

For benchmarking, `generate-votes.sh` uses the `ab` utility which needs to be installed, through the `apache2-utils` `apt` package.

### `worker` service

This is a .NET (C#) program that reads vote submissions from Redis store, compute the result and store it in the PostgreSQL database.

It requires a little bit more work to compile and run:
- use this as a base image
```
mcr.microsoft.com/dotnet/sdk:8.0
```
  with the argument `--platform=${BUILDPLATFORM}`
- use `ARG` to define build arguments `TARGETPLATFORM`, `TARGETARCH` and `BUILDPLATFORM`. Print their values with `echo`.
- in the `source/` directory, copy all worker files form this repo and run
```
dotnet restore -a $TARGETARCH
dotnet publish -c release -o /app -a $TARGETARCH --self-contained false --no-restore
```
The application will be built inside the `/app` directory, launch with `dotnet Worker.dll`.

For the multistage build, use this image: `mcr.microsoft.com/dotnet/runtime:8.0`.


### Nginx loadbalancer service

This is a simple Nginx service. At its core, Nginx is a web-server but it can also be used for other purposes such as loadbalancing, HTTP cache, reverse proxy, etc.

Use the base image `nginx`.

To configure Nginx as a loadbalancer (LB), you first need to edit accordingly the `./nginx/nginx.conf` file from this repo.
Then in the Dockerfile:
- remove the default Nginx configuration located at `/etc/nginx/conf.d/default.conf`,
- copy `./nginx/nginx.conf` into the container at the above location.

### Redis service

This is a simple Redis service directly deployed in the `docker-compose.yaml` file without a `Dockerfile`. Redis is a NOSQL database software focused on availability used for storing large volumes of data-structures (typically key-value pairs).

use the base image `redis:alpine`

In order to perform healthchecks while Redis is running, there must be a volume attached to the container. You will need to mount local the repo directory `./healthchecks/` into the `/healthchecks/` directory of the container.

The check is done by executing the `redis.sh` script.


### PostgreSQL database service

This is a simple PostgreSQL service directly deployed in the `docker-compose.yaml` file without a `Dockerfile`.

Use the base image `postgres:15-alpine`

The same logic applies for healthchecks, mount a volume, use `postgres.sh` for running checks.

Moreover, in order to persist the data that comes from the votes, you need to create a Docker volume and attach it to the container.
The volume will be named `db-data` and attached to the `/var/lib/postgresql/data` directory inside the container.

### Networking

* The Redis store, the `worker` service and the PostgreSQL database are only available inside the `back-tier` network.
* The `vote` and `result` services are on both the `front-tier` and `back-tier` network in order to (1) expose the frontend to users, and (2) communicate with the databases.
* Finally, the `seed` and Nginx loadbalancer are on the `front-tier`.



# Kubernetes project

The goal of this project is to deploy the previous application to a Kubernetes cluster. 

![image](login-nuage-voting-k8s.drawio.svg)

## Preliminary phase (1): push your Docker images into a GCP container registry

1. In the GCP dashboard, go to *Artifact Registry* and create a *Repository*.
Give it a name e.g. `voting-image`, and a *region* e.g. `europe-west3`.
Once created, inspect the repository and copy its path, it should look something like `europe-west3-docker.pkg.dev/your-gcp-project/voting-image`.

1. Before pushing to the registry, issue the following command in order to authenticate your laptop to the registry:
```
gcloud auth configure-docker europe-west3-docker.pkg.dev
```
Note that this command can be found in the "Setup Instructions" button in the registry repo.

1. We then need to tag the images with the corresponding registry path, followed by their original name. We can do it *either* in bulk with bare Docker Compose or one by one with Docker.

    * Option 1: Within `docker-compose.yml` file, for each service that `build`s an image, add the `image` field. E.g. for the `result` service:
      ```
      result:
        image: europe-west3-docker.pkg.dev/your-gcp-project/voting-image/result
        build:
          context: ./result
      ```
      Re-build the images with `docker compose build` and verify with `docker image ls`.

    * Option 2: For each service we need to build the image and tag the resulting hash. E.g. with `result`:
        * `docker build result/`
        * `docker tag 0cc5784ad220 europe-west3-docker.pkg.dev/nuage-k8s/login-nuage-images/result`

1. Finally, push the images. Either
    * with Docker Compose: `docker compose push`
    * or with Docker, e.g. `docker push europe-west3-docker.pkg.dev/your-gcp-project/voting-image/result`


* In case you struggle making this work, you can use our public images from Docker Hub during the session (not in the repo you will send us).
  The tags are prefixed with `eloip13009`, for example `eloip13009/result`.
  The suffixes are `vote`, `result`, `worker` and `seed-data`
  <!-- `postgres-hs` and `redis-hs`. -->

You will notice that for the `seed-data` image, the public version only sends a total of 300 votes, instead of 3000 previously.

## Preliminary phase (2): build your Docker images in Minikube's Docker runtime

Minikube can store local images to be used in the cluster.
The subcommand is `minikube image`, and the documentation can be found [here](https://minikube.sigs.k8s.io/docs/handbook/pushing/#1-pushing-directly-to-the-in-cluster-docker-daemon-docker-env). It works similarly to `docker image`, so we can use `minikube image ls` to show the images, `rm` to remove images, etc.

In order to build your images directly onto the Minikube runtime, the command is

```
minikube image build .
```
where `.` is the path containing the Dockerfile.
The name of the image looks like this `docker.io/library/result:latest`.

In the specification of Pods using local images, you must use the "name" of the image, e.g. `result`, and add the `imagePullPolicy: Never` field indicating Minikube _not_ to pull the image from a remote location but use the local image.
For example in a Deployment,

```
spec:
  template:
    spec:
      - image: result
        imagePullPolicy: Never
```



## Mandatory version

<!-- -->

Deploy a working application (with temporary database store)

* `vote`, `result`, `redis` and `db`, each with a `Deployment` and a `Service` (choose the good type).
* `worker` only needs a `Deployment`.
* Make the data of the `db` persist even if the associated pod is deleted
    - Use a `PersistentVolumeClaim`
    - In the corresponding `Deployment`, under `volumeMounts`, there should be `subPath: data`
* `seed` will be run as a `Job` that is *not restarted*.
* Add `livenessProbe`s to reflect the `healthchecks` of last week's Docker project.
    * `result` and `vote` use the `httpGet` probe.
    * `redis` and `db` use the `exec` probe to run the `healthchecks/{redis.sh,postgres}.sh` scripts.
        - TIP: You have to create an image for redis and postgres with sh files included, or better use an init container to get [healthchecks files](https://gitlab.imt-atlantique.fr/login-nuage/healthchecks/) inside a shared volume [see this page](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)

## Optional extensions

The two extensions are independent.

1. Add `livenessProbe`s to reflect the `healthchecks` of last week's Docker project.
    * `redis` and `db` use the `exec` probe to run the `healthchecks/{redis.sh,postgres}.sh` scripts.
        - TIP: You have to create an image for redis and postgres with sh files included, or better use an init container to get [healthchecks files](https://gitlab.imt-atlantique.fr/login-nuage/healthchecks/) inside a shared volume [see this page](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
2. Use an `HorizontalPodAutoscaler` to automatically scale the number of replicas for `vote` (make sure to understand monitoring metrics and triggering mechanisms!)
    * TIP: with Minikube, you will have to run the "metric server": `minikube addons enable metrics-server`
3. Use a `ConfigMap` to pass values to your pods as environment variables
    1. create the `ConfigMap` with a manually created manifest
    2. use `Kustomize` to generate the `ConfigMap` 

<!-- -->

## Appendix: Useful commands

Print the list of resources we can declare in a manifest, i.e. available values of `apiVersion` and `kind`

    kubectl api-resources

Print details about a specific resource or group of resources. For example if an HPA is misbehaving, you may debug with

    kubectl describe hpa

Print the documentation of a resource, i.e. the accepted fields in the manifest

    kubectl explain deployment.spec.template.spec.containers.livenessProbe


Print the logs of a container. When selecting a pod, `kubectl` will choose one. The `-f` options means "follow", i.e. print the logs continuously, akin to the Linux `tail -f` command.

    kubectl logs -f pods/vote<TAB>


Apply *all* manifests of a repository

    kubectl apply -f k8s-manifests/


Show resources continuously (refreshed every one second) with `watch`. Beware, `all` do not mean *all* resources, only "user" resources. E.g. `PersistentVolume`s and `StorageClass`es are not showed.

    watch -n1 kubectl get all


Execute a command in a container. E.g. dump the `votes` table in the Postgres pod.

    kubectl exec pods/db<TAB> -- pg_dump -U postgres -t public/votes


For commands that handle resources, the `-l` option applies it on resources holding the specified `labels`. E.g. to delete all resources related to the voting app (those with `metadata.labels.app = vote`)

    kubectl delete all -lapp=vote

# Ansible project

See the dedicated website at https://ue-devops-fila2.gitlab-pages.imt-atlantique.fr/cours-ansible-voting-app/docs/1-intro/1-infra-hybride/.

# Terraform project

**WARNING!!!! For FISE LOGIN only! (not FIL A2)**

## Objectives

The objective is to use Terraform to deploy the voting app.

The tutorial on Terraform did not give you _all_ elements for this project: it was on purpose.
The point is for you to learn how to seek information in providers and other documentations.
But most elements in the tutorials can be directly applied.

**IMPORTANT**: Make sure to organize your Terraform code well. Attention will be given to the repo organization, README, variable files, etc.
The different parts of Terraform code should be segmented within directories. To be able to use the data from other directories, use either a local _module_ or a `terraform_remote_state` resource which allows you to refer to output variables.

Different levels are possible, the more advancement you make the better.

## Part 1 - Docker

In this first part, you must deploy the application with the Terraform Docker provider.
The app will thus be deployed locally inside containers on your machine.

### Mandatory

1. Write the code that __builds__ the images from your local Dockerfiles
2. Write the code that __creates__ the appropriate containers.

**TIP**: start from your previous `docker-compose.yml`.

### Optional

3. Modify the image resources so that they are rebuilt each time the code of the service changes.
4. Use Terraform to push the images into a GCP Artifact Registry.

## Part 2 - GCP and Kubernetes

In this second part, you will deploy the application onto a Kubernetes cluster provisioned with Terraform on GCP.
Google and Kubernetes providers will be thus be used.

### Mandatory

1. Write the code that creates a GKE (Google Kubernetes Engine) cluster. Make sure to use only one node for the whole cluster. For this, use a _zone_ in the `location`, and set the node count to 1.

**TIP**: Make sure to add `deletion_protection = true` to the cluster resource so that Terraform can delete it later.

2. Reuse your YAML manifests within Terraform to deploy the application. Use only the `kubernetes_manifest` resource type.

__TIP__: To configure the Kubernetes provider, use and complete the code inside `gke-config.tf` in the repo.


### Optional

3. Create a Terraform variable to configure the PostgreSQL password.


## Part 3 Optional - GCP, Kubernetes and Redis on its own VM

In this last part, the objective is to decouple the Redis database from the Kubernetes cluster.
Instead of a simple container in a Pod, Redis will be deployed in its own VM provisioned on GCP.
This database must then communicate with the other components of the application located on the cluster.

### Preliminary changes to the code

By default, Redis is supposed to be used only locally and does not have a password.
So you must modify the application code that uses Redis so that they connect with a password.

#### Inside `vote/app.py`

On line 21, change
```
    g.redis = Redis(host="redis", db=0, socket_timeout=5)
```
to
```
    g.redis = Redis(host="redis", password="toto", db=0, socket_timeout=5)
```

#### Inside `worker/Program.cs`

On line 116, change
```
    return ConnectionMultiplexer.Connect(ipAddress);
```
to
```
    return ConnectionMultiplexer.Connect("redis,password=toto");
```

#### cloud-init script to install Redis on a VM

Use this script as cloud-init userdata to install Redis.
```
#!/usr/bin/env bash
#
# Install and configure Redis

DEBIAN_FRONTEND=noninteractive apt update -q
DEBIAN_FRONTEND=noninteractive apt install -q -y redis

sed -e '/^bind/s/bind.*/bind 0.0.0.0/' -i /etc/redis/redis.conf
sed -e '/# requirepass/s/.*/requirepass toto/' -i /etc/redis/redis.conf
```

### Changes to the manifests

To make the database available to the other components of the application located on the cluster,
you will have to update the Kubernetes manifests, notably, the previous Redis service must be changed to a "headless" service.

__TIP__: vote and worker need to be aware of the Redis _host IP_ and _password_.


### Network access to download Redis

By default, the VMs on GCP do not have a public IP to access the internet, so the install script will not work.
You will have to update networking policies to make it work. For the purpose of this project, this can be done manually.


## Destroy everything

To keep some credits, make sure your resources (in particular the GKE cluster) is deleted.
The easiest way is to run `terraform destroy`.

If you are surprised with an error saying that the GKE cluster cannot be destroyed, it means you forgot to disable the `deletion_protection` in the resource.

<!-- Open `terraform.tfstate`, look for the property `deletion_protection` and set its value to `false`. -->

<!-- Alternatively, use `sed`: -->
<!-- ``` -->
<!--     sed -e '/deletion_protection/s/true/false/' -i terraform.tfstate -->
<!-- ``` -->

