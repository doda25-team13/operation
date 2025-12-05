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

```bash
# Install Helm Chart
helm install app-stack ./app-stack -f app-stack/values.yaml

# Check pods
kubectl get pods

# Access app via Ingress (requires ingress controller)
minikube tunnel  # if using minikube
```

## Accessing the app

(One time) add ip to `/etc/hosts`

```bash
#take minikube ip and add it to the /etc/hosts file
sudo sh -c "echo $(minikube ip) app.stable.example.com >> /etc/hosts"

# check that change was successfull
sudo nano /etc/hosts

```

Go to http://app.stable.example.com/sms
