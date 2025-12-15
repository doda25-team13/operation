# Deployment Overview
{Introduction}

## System context

The system is deployed into an already existing Kubernetes cluster. The cluster provides the following:
- A Kubernettes control pane and worker nodes
- An Istio service mesh instalation
- An Istio IngressGateway

The application is installed using a Helm chart. All Kubernetes and Istio resources related to the application are installed through this Helm chart. The Istio IngressGateway is not part of the Helm chart and is an external dependency.

## Deployed Components

### Application
{Services and versions}
### Traffic Management (Istio)
{Gateway, VirtualService, DestinationRules}

### Observability
{Prometheus and Grafana}

## Deployment Architecture
{Diagram}
## Access to Application

## Request Flow

## Canary Releases

## Observability and Metrics

## Additional Istio Use Case