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

Grafana might require credentials, this can be decoded from the repository: \
username: admin \
password: prom-operator // or try admin or admin123 

For the prometheus, check under Status --> Target to verify that the correct endpoints are being scraped, alternatively you can verify by querying you self or viewing the http://app.stable.example.com/metrics

To find our dashboard, go to Dashboards --> App Usability Metrics

You can generate some traffic by opening another terminal and run this:
```bash
# Keep this running in a separate terminal window
while true; do 
  curl -s -o /dev/null http://app.stable.example.com/sms
  echo "Request sent..."
  sleep 1
done
```

You should observe changes in the dashboard 

### Known issues:
The /metrics api provides wrong data \
The pods takes awfully long to initialize until they run on Kevin's machine (after merging enable-monitoring) \
Some warning / bugged output when installing the release with Helm  
