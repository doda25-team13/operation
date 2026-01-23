# Running the Application with Docker Compose
This project includes a `docker-compose.yml` file which runs both services:
- **app** (frontend service)
- **model-service** (ML backend service)

To run the docker compose file, first create a `.env` file in the same directory as `docker-compose.yml` and set the port environmental variables:
```bash
APP_HOST_PORT=8080
APP_CONTAINER_PORT=8080
MODEL_SERVICE_PORT=8081
```
Run the following command to start the services:
```bash
cd /path/to/project/
sudo docker compose up --pull always
```
Frontend service will be available on port `APP_HOST_PORT` (e.g., [localhost:8080/sms/](http://localhost:8080/sms/)).\
\
To stop the services run:
```bash
sudo docker compose down
```

To check the logs run:
```bash
sudo docker compose logs -f
```
# Running the Application with Vagrant (A2) 
Requires virtual environment for python , activate it by : 
```bash
 source .venv/bin/activate
```
Check if vagrant, Ansible and VirtualBox are installed by checking their version 

If kvm is enabled, you might have to disable it, depending on which CPU you have: 
```bash
sudo modprobe -r kvm_amd 
sudo modprobe -r kvm_intel
```
Start the vagrant (This will look at the configuration from the Vagrant file in the folder) 
```bash
vagrant up
```

You now should be able to ssh into one the (ctrl / worker) nodes, and the content of a node should be visible on your local browser on their IP adress + port (See tutorial W3 or follow up implementation) 

In the case that ssh requires credentials:
username: vagrant
pw:       vagrant 

If your public key is in the public keys folder, this command should omit the need for this, for an example for Node 1 
```bash 
ssh -i ~/.ssh/id_ed25519 vagrant@192.168.56.101
```



# Running in Kubernetes (A3)

## Intial minikube setup
```bash
minikube start --driver=docker # can be replaced with --driver=virtualbox if issues arise

# Make sure Ingress controller is enabled
minikube addons enable ingress
```

## Update dependencies
```bash
# Navigate to app-stack
cd app-stack

# Update dependencies
helm dependency update

# navigate back to root
cd ../
```

## Project setup
```bash
# Install Helm Chart
helm install app-stack ./app-stack -f app-stack/values.yaml

# Check that pods are ready
kubectl get pods
```

## Local ip setup 
(One time) add ip to `/etc/hosts`

```bash
#take minikube ip and add it to the /etc/hosts file
sudo sh -c "echo $(minikube ip) app.stable.example.com >> /etc/hosts"

# check that change was successfull
sudo nano /etc/hosts
```

## Access app via Ingress (requires ingress controller)
```bash
minikube tunnel  # if using minikube
```

Go to http://app.stable.example.com/sms

## Access the Prometheus UI
```bash
# Port forward prometheus service
kubectl port-forward svc/app-stack-kube-prometheus-prometheus 9090:9090 -n default
```

Prometheus should be available at http://localhost:9090 \
Check the services that are being scrpaed at Status --> Targets in the Prometheus UI


## Access Grafana
Forward  grafana to any port, for an example 3000 \
You can use the & to run the command in the background, omitting opening another terminal
```bash
kubectl port-forward svc/app-stack-grafana 3000:80 & 
```
You can then view the grafana UI on http://localhost:3000

Grafana login requires credentials from the values.yaml: \
username: admin \
password: admin123 // or try prom-operator or admin 

To find our basic dashboard, go to Dashboards --> App Usability Metrics \
To find our ab-testing dashboard, go to Dashboards --> Requests Comparison Dashboard \
You can generate some traffic by manually sending some requests youself on the /sms page \


You should observe changes in the dashboard 


## Test Email Alerts
Alert has been defined in the values.yaml
The behaviour of the alertmanager is defined in the template/alert-manager-secret.yaml
Placeholder values for the smtpUser , smtpPassword are defined in the values.yaml 
The current alert is very simpel and prone to trigger (total_request >= 2) for testing purposes
It sends an email to itself, 

Start the application overriding the placeholder with actual email, and app password (note that this is not your usual password, also it must be without spaces) 
```
helm install app-stack ./app-stack -f app-stack/values.yaml \
  --set secret.smtpUser=real@email.com \
  --set secret.smtpPass=realpassword
```

### Troubleshoot
If you did not receive the email: check if the Prometheus has fired the alert under the tab Alerts
Also check if you spelled your credentials correctly.

## Traffic Management (A4)

### Prerequisites
- Kubernetes cluster
- Istio installed
- kubectl and curl installed
- Helm

Start kubernetes cluster with minikube and install istio. Istio installation recommends 4 CPU cores.
```bash
minikube start --cpus=4 --memory=8192 --driver=docker

# Install Istio 
istioctl install
kubectl label namespace default istio-injection=enabled --overwrite
 
helm install app-stack ./app-stack

# Install monitoring addons from istio samples folder
kubectl apply -f <path to istio>/samples/addons/prometheus.yaml
kubectl apply -f <path to istio>/samples/addons/kiali.yaml 

# Verify pods are up 
kubectl get pods
```
---
To test canary split run the shell script that spins up a container that curls the app 100 times to check the canary split.
```bash
bash test-scripts/test-canary-split.sh
```
OR to manually test the canary split:

Run `minikube tunnel` following the [update](#local-ip-setup-) to `/etc/hosts` (which you should've done for previous steps)
You can find the app running on Go to http://app.stable.example.com/sms

We simulated testing by simulating traffic on the browser and verifying the routing on the Kiali dahsboard which can be started by running `istioctl dashboard kiali`

Sticky sessions are enabled by default, so the same user will always be routed to the same pod. This is implemented by setting cookies on the first request and using them on subsequent requests.

To test sticky sessions, run the following shell script which curls the app after setting cookies on the first request.
```bash
bash test-scripts/test-sticky.sh
```
Expected output:
```
pod/sticky-test created
pod/sticky-test condition met
  21 v2
pod "sticky-test" deleted from default namespace
```
**1st request**: went to v1 (or v2)  
**subsequent 20 requests**: go to the same version
## Istio Rate Limiting Demo

The following commands show how to deploy Redis + Envoy Ratelimit and test global rate limiting using Istio ingressgateway. 

Note: The limit only applies to the `/sms/` path, as to not create issues with other components of the application.

### Testing Rate Limiting

To test the global limit, run the following shell script which curls the app 20 times:
```bash
bash test-scripts/test-global-rate-limit.sh
```

Or to test manually:
```bash
# Follow steps from previous section ## Traffic Management

# Verify the pod:
kubectl get pods -n istio-system

minikube tunnel


# Test the global limit 
for i in {1..15}; do
  curl -s -o /dev/null -w "Request $i: %{http_code}\n" http://app.stable.example.com/sms/
done
```

Expected output:

```bash
Request 1: 200
Request 2: 200
...
Request 10: 200
Request 11: 429
Request 12: 429
...
```

# Test the user-specific limit 
```bash
for i in {1..6}; do
  curl -s -o /dev/null \
    -H "x-user-id: user1" \
    -w "user1 Request $i: %{http_code}\n" \
    http://app.stable.example.com/sms/
done

for i in {1..6}; do
  curl -s -o /dev/null \
    -H "x-user-id: user2" \
    -w "user2 Request $i: %{http_code}\n" \
    http://app.stable.example.com/sms/
done
```

Expected Output:

- First 4 requests (user1) are allowed
- Last 2 Requests (user1) are rejected
- First 4 requests (user2) are allowed
- Last 2 requests (user2) are rejected


### If encountering issues
Minikube + VirtualBox requires NodePort exposure for ingressgateway because LoadBalancer type doesn’t work locally.

If using VirtualBox as a driver, this might help with the 500 error:

```bash
kubectl patch svc istio-ingressgateway \
  -n istio-system \
  --type merge \
  -p '{"spec":{"type":"NodePort"}}'

kubectl get svc -n istio-system istio-ingressgateway
```

Get the `:80` port, append it to curl address. For example:

```bash
for i in {1..15}; do
  curl -i http://app.stable.example.com:30971/sms/
done
```
