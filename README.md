# Running the Application with Docker Compose
This project includes a `docker-compose.yml` file which runs both services:
- **app** (frontend service)
- **model-service** (ML backend service)

To run the docker compose file, first create a `.env` file in the same directory as `docker-compose.yml` and set the port environmental variables:
```bash
APP_PORT=8080
MODEL_SERVICE_PORT=8081
```
Run the following command to start the services:
```bash
cd /path/to/project/
sudo docker compose up -d
```
Frontend service will be available on port `APP_PORT` (e.g., [localhost:8080/](http://localhost:8080/)), while backend service will be available on port `MODEL_SERVICE_PORT` (e.g., [localhost:8081/](http://localhost:8081/)). \
\
To stop the services run:
```bash
sudo docker compose down
```

To check the logs run:
```bash
sudo docker compose logs -f
```