# Project 4 - Terraform Kubernetes Application

## Overview

This is a local educational DevOps project that deploys a containerized application on Kubernetes using Terraform.

The project includes:
- FastAPI application
- Redis for caching and application data
- Nginx as a reverse proxy
- Kubernetes Deployments, Services, and ConfigMap
- Prometheus monitoring
- Grafana dashboard for application metrics

## Architecture

Browser
  -> Nginx (NodePort 30081)
  -> FastAPI (ClusterIP, port 8000)
  -> Redis (ClusterIP, port 6379)

Prometheus collects FastAPI metrics, and Grafana visualizes them.

## Technologies

- Terraform
- Kubernetes
- Docker
- FastAPI
- Redis
- Nginx
- Prometheus
- Grafana
- Helm
- PowerShell

## Prerequisites

- Windows with PowerShell
- Docker Desktop with Kubernetes enabled
- kubectl
- Terraform
- Helm
- An existing local Kubernetes cluster

## Deployment

Initialize Terraform:

    terraform init

Review the planned changes:

    terraform plan

Apply the configuration:

    terraform apply

Review the created Terraform resources:

    terraform state list

## Application Access

The Nginx Service uses NodePort 30081. On this local Docker Desktop setup, port-forwarding can be used to access it:

    kubectl port-forward service/nginx-service 30081:80 -n project4

Open:

    http://localhost:30081

To access the FastAPI Swagger UI directly, open another PowerShell terminal and run:

    kubectl port-forward service/fastapi-service 8000:8000 -n project4

Then visit:

    http://localhost:8000/docs

Keep the relevant port-forward terminal open while testing.

## Monitoring

Prometheus and Grafana use the existing shared Kubernetes namespace named monitoring. They are not separate Terraform-managed resources in this project.

The Prometheus configuration includes a scrape job for Project 4:

    fastapi-service.project4.svc.cluster.local:8000

The existing Project 3 scrape job is preserved.

The Grafana dashboard includes panels for:
- HTTP request rate
- HTTP errors
- Total HTTP requests
- Application memory usage
- Cache endpoint request rate

The cache request-rate panel measures traffic to the /cache endpoint; it does not directly measure Redis server internals.

The file prometheus-values.yaml contains Prometheus Helm values used to configure the existing shared Prometheus release.

## Terraform State and Security

Terraform state files and the .terraform directory are excluded through .gitignore.

The .terraform.lock.hcl file is retained to record the selected Terraform provider versions.

## Scope

This project is intended for local learning and interview preparation. It is not presented as a production-ready, highly available deployment.

