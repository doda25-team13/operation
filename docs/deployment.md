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

The application consists of two services - frontend (**app**) and backend (**model-service**). They are both deployed in two versions.

- **app-service**

    - v1 (stable)
    - v2 (experimental)
    - Exposes REST API used by the frontend
    - Delegates classification tasks to the backend

- **model-service**

    - v1 (stable)
    - v2 (experimental)
    - Exposes REST API for SMS classification

### Traffic Management (Istio)

The following Istio resources are deployed:

- **Gateway**
    - Used to bind the application to the externally provided IngressGateway
    - Sets hostnames and ports used to access the application

- **VirtualService**
    - Defines the HTTP routing rules
    - Implements canary routing to split traffic between v1 (stable) and v2 (experimental) of **app-service**

- **DestinationRules**
    - ...

### Observability

- **Prometheus**
    - Deployed as part of the Helm chart
    - Scrapes application metrics from the frontend

- **Grafana**
    - Deployed alongside Prometheus
    - Provides a dashboard for monitoring and experimental evaluation

## Deployment Architecture
{Diagram}
## Access to Application

The application is accessed through an Istio IngressGateway, using an HTTP endpoint

- **Hostname**: Configured through Helm values (*app.stable.example.com*)

- **Port**: 80

- **Protocol**: HTTP

The Istio Gatweay binds the hostname to the IngressGateway. All incoming traffics goes through the VirtualService to be routed to the two different deployed service versions.

## Request Flow
An example request flow:
1. A user sends an **HTTP request** to the hostname
2. The request goes to the cluster through the **IngressGateway**
3. The request is accepted and forwarded to **VirtualService**
4. **VirtualService** assignes the request to either **app-service** v1 (stable) or v2 (experimental)
5. The **app** processes the request and calls either **model-service** v1 (stable) or v2 (experimental)
6. **model-service** performs the classification task
7. The result is propagated back to the user following the same steps 

## Traffic Control: Rate Limiting

To protect the application from excessive usage and to ensure fair access, rate limiting is enforced at the Istio IngressGateway.

Incoming HTTP requests are evaluated before routing by an Envoy rate-limit filter, integrated into the gateway. Requests sent after the configured limit is reached are immediately rejected with an HTTP 429 (Too Many Requests) response and are not forwarded to the application service.

These rate limits are applied only to the `/sms/` endpoint, while operational endpoints (such as `/metrics`) remain unrestricted.

## Canary Releases

Canary releases are implemented using Istio wighted routing:
- 90% of requests are routed to **app-service** v1 (stable)
- 10% of requests are routed to **app-service** v2 (experimental)

To ensure consistency during experimentation, v1 of **app-service** is only allowed to communicate with v1 of **model-service** and, respectively, v2 of **app-service** is only allowed to communicate with v2 of **model-service**.

{Destination rules}

## Observability and Metrics

The **app-service** exposes Prometheus metrics on */metrics* that capture user behaviour and system performance. These include counters, gauges and histograms.

Prometheus scrapes the metrics from the frontend and stores them as time-series data. Grafana takes the data from Prometheus and visualizes it in the form of dashboards, which enables easy monitoring and comparisons between the stable and experimental versions.
