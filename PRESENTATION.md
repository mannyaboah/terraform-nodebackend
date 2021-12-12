# Emmanuel Aboah CS-E90 Final Project

![IaC](IaC.png)

# What is Infrastructure As Code 🤔? 
Infrastructure as Code (IaC) is the management of infrastructure (networks, virtual machines, load balancers, and connection topology) in a descriptive model, using the same versioning as DevOps team uses for source code. Like the principle that the same source code generates the same binary, an IaC model generates the same environment every time it is applied. IaC is a key DevOps practice and is used in conjunction with continuous delivery.

- Write and execute code to define, deploy, and update an infrastructure
- Almost all parts of the infrastructure managed as code, including:
    - Servers
    - Storage (structured and unstructured)
    - Networks
    - Application configuration
- Create standard, repeatable processes for building, modifying, and destroying entire environments

## Disposable Infrastructure 🗑️🖥️
- Machines in the cloud need to be disposable
    - Don’t fix broken machines
    - Don’t install patches
    - Don’t upgrades machines
- If you need to fix a machine, delete it and recreate a new one
- To make infrastructure disposable, automate everything with code
    - Can automate using scripts
    - Can use declarative tools to define infrastructure

## Why IaC 🤷🏾‍♀️?
- IaC allows for the quick provisioning and removing of infrastructures
    - Build an infrastructure when needed
    - Destroy the infrastructure when not in use
    - Results in reduced cloud costs
- Create identical infrastructures for dev, test, and prod
- Can be part of a CI/CD pipeline
- Templates are the building blocks for disaster recovery procedures

---

![Docker](docker-logo.png)

# Docker

A **container** is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another. A Docker container image is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings.

Container **images** become containers at runtime and in the case of Docker containers - images become containers when they run on Docker Engine. Available for both Linux and Windows-based applications, containerized software will always run the same, regardless of the infrastructure. Containers isolate software from its environment and ensure that it works uniformly despite differences for instance between development and staging.

A **registry** is used as a repository to store container images. In this projest we use dockerhub.

---

![K8s](Kubernetes_AIM.jpg)

# Kubernetes K8s ☸️ 

Kubernetes is a portable, extensible, open-source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation. It has a large, rapidly growing ecosystem. Kubernetes services, support, and tools are widely available.

The name Kubernetes originates from Greek, meaning helmsman or pilot. K8s as an abbreviation results from counting the eight letters between the "K" and the "s". Google open-sourced the Kubernetes project in 2014. Kubernetes combines over 15 years of Google's experience running production workloads at scale with best-of-breed ideas and practices from the community.

## Deployments: 
A Deployment provides declarative updates for Pods and ReplicaSets.

You describe a desired state in a Deployment, and the Deployment Controller changes the actual state to the desired state at a controlled rate. You can define Deployments to create new ReplicaSets, or to remove existing Deployments and adopt all their resources with new Deployments.

### In this proeject we have two deployments to demostrate microservices:

### Backend app -> nodebackend

```js
'use strict';

// express is a nodejs web server
// https://www.npmjs.com/package/express
const express = require('express');

// converts content in the request into parameter req.body
// https://www.npmjs.com/package/body-parser
const bodyParser = require('body-parser');

// create the server
const app = express();

// the backend server will parse json, not a form request
app.use(bodyParser.json());

// allow AJAX calls from 3rd party domains
app.use(function (req, res, next) {
	res.header("Access-Control-Allow-Origin", "*");
    res.header('Access-Control-Allow-Methods', 'PUT, POST, PATCH, MERGE, GET, DELETE, OPTIONS');
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
})

// mock events data - for a real solution this data should be coming 
// from a cloud data store
const mockEvents = {
    events: [
        { title: 'an event', id: 1, description: 'something really cool' },
        { title: 'another event', id: 2, description: 'something even cooler' }
    ]
};

// health endpoint - returns an empty array
app.get('/', (req, res) => {
    res.json([]);
});

// version endpoint to provide easy convient method to demonstrating tests pass/fail
app.get('/version', (req, res) => {
    res.json({ version: '1.0.0' });
});

// mock events endpoint. this would be replaced by a call to a datastore
// if you went on to develop this as a real application.
app.get('/events', (req, res) => {
    res.json(mockEvents);
});

// Adds an event - in a real solution, this would insert into a cloud datastore.
// Currently this simply adds an event to the mock array in memory
// this will produce unexpected behavior in a stateless kubernetes cluster. 
app.post('/event', (req, res) => {
    // create a new object from the json data and add an id
    const ev = { 
        title: req.body.title, 
        description: req.body.description,
        id : mockEvents.events.length + 1
     }
    // add to the mock array
    mockEvents.events.push(ev);
    // return the complete array
    res.json(mockEvents);
});

app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: err.message });
});

const PORT = process.env.PORT ? process.env.PORT : 8082;
const server = app.listen(PORT, () => {
    const host = server.address().address;
    const port = server.address().port;
    console.log(`Events app listening at http://${host}:${port}`);
});

module.exports = app;
```


### Frontend app -> nodefrontend

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <title>Frontend Event Feed</title>
  <meta name="HandheldFriendly" content="True" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
</head>
<body>
  <div>
      <h1>Welcome to the Frontend application</h1>
    {{{body}}}
</div>
<div>
  <h2>Add an event</h2>
    <form action="/event" method="post">
       title: <input name="title" type="text" /> <br />
       description: <input name="description" type="text" /> <br />
       <br />
        <input type="submit" name="submit" value="submit" />
    </form>
  </div>
</body>
</html>
```

### kubernetes-nodebackend-deployment.tf

```go
resource "kubernetes_deployment" "nodebackend-deployment" {
  metadata {
    name = "nodebackend-deployment"
    labels = {
      App = "nodebackend"
    }
    namespace = kubernetes_namespace.n.metadata[0].name
  }

  spec {
    replicas                  = 4
    progress_deadline_seconds = 60
    selector {
      match_labels = {
        App = "nodebackend"
      }
    }
    template {
      metadata {
        labels = {
          App = "nodebackend"
        }
      }
      spec {
        container {
          image = "mannyaboah/nodebackend:v0.1"
          name  = "nodebackend"

          env {
            name  = "PORT"
            value = "8082"
          }

          port {
            container_port = 8082
          }

          resources {
            limits = {
              cpu    = "0.2"
              memory = "2562Mi"
            }
            requests = {
              cpu    = "0.1"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}
```

### kubernetes-front-deployment.tf

```go
resource "kubernetes_deployment" "nodefrontend-deployment" {
  metadata {
    name = "nodefrontend-deployment"
    labels = {
      App = "nodefrontend"
    }
    namespace = kubernetes_namespace.n.metadata[0].name
  }

  spec {
    replicas                  = 2
    progress_deadline_seconds = 90
    selector {
      match_labels = {
        App = "nodefrontend"
      }
    }
    template {
      metadata {
        labels = {
          App = "nodefrontend"
        }
      }
      spec {
        container {
          image = "mannyaboah/nodefrontend:v0.1"
          name  = "nodefrontend"

          env {
            name  = "SERVER"
            value = "http://nodebackend-service:8082"
          }

          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = "0.2"
              memory = "2562Mi"
            }
            requests = {
              cpu    = "0.1"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}
```

## Namespace:
In Kubernetes, namespaces provides a mechanism for isolating groups of resources within a single cluster. Names of resources need to be unique within a namespace, but not across namespaces. Namespace-based scoping is applicable only for namespaced objects (e.g. Deployments, Services, etc) and not for cluster-wide objects (e.g. StorageClass, Nodes, PersistentVolumes, etc).

In this project we use one namespace "nodebackend" to organize our entire application stack and network.

### kubernetes-namespace-node.tf

```go
resource "kubernetes_namespace" "n" {
  metadata {
    name = "nodebackend"
  }
}
```

## load balancer:
When creating a Service, you have the option of automatically creating a cloud load balancer. This provides an externally-accessible IP address that sends traffic to the correct port on your cluster nodes, provided your cluster runs in a supported environment and is configured with the correct cloud load balancer provider package.
You can also use an Ingress in place of Service.

In this project we use a load balancer service to expose our frontend app to the outside world.

### kubernetes-nodebackend-load-balancer.tf

```go
resource "kubernetes_service" "nodefrontend-service" {
  metadata {
    name      = "nodefrontend-service"
    namespace = kubernetes_namespace.n.metadata[0].name
  }
  spec {
    selector = {
      App = kubernetes_deployment.nodefrontend-deployment.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = kubernetes_service.nodefrontend-service.status.0.load_balancer.0.ingress.0.ip
}
output "lb_status" {
  value = kubernetes_service.nodefrontend-service.status
}
```

## clusterIp:
Used to define a load balancer service internal to the local network to route messages in the cluster.

In this project a clusterIP is used to send messages from the exposed frontend application to the backend application.

### kubernetes-nodebackend-clusterip.tf

```go
resource "kubernetes_service" "nodebackend-service" {
  metadata {
    name      = "nodebackend-service"
    namespace = kubernetes_namespace.n.metadata[0].name
  }
  spec {
    selector = {
      App = kubernetes_deployment.nodebackend-deployment.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 8082
      target_port = 8082
    }

    type = "ClusterIP"
  }
}
```

## Project Repositories:
- [Frontend App](https://github.com/mannyaboah/AdvDevOpsLearning-Frontend)
- [Backend App](https://github.com/mannyaboah/AdvDevOpsLearning-Backend)
- [K8s scripts](https://github.com/mannyaboah/devops-bootcamp-k8s)
- [Terraform code](https://github.com/mannyaboah/terraform-nodebackend)