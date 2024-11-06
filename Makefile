# Makefile to automate Apache2 setup, Docker and Kubernetes tasks

# Variables
APACHE_DIR=/var/www/html
WEBSITE_SRC=~/static-website
DOCKER_IMAGE_NAME=my-website
DOCKER_IMAGE_TAG=latest
K8S_DEPLOYMENT_NAME=my-website-deployment
K8S_SERVICE_NAME=my-website-service
NODE_PORT=30088

# Step 1: Uninstall Apache2 and Reinstall it
install-apache:
	@echo "Uninstalling Apache2..."
	@echo "#!/bin/bash\n\
	# Uninstall Apache2\n\
	echo 'Stopping Apache2...'\n\
	sudo systemctl stop apache2\n\
	echo 'Removing Apache2...'\n\
	sudo apt remove apache2 --purge -y\n\
	echo 'Removing unused packages...'\n\
	sudo apt autoremove --purge -y\n\
	echo 'Removing Apache2 directories...'\n\
	sudo rm -rf /etc/apache2 /var/www/html\n\
	# Reinstall Apache2\n\
	echo 'Updating package list...'\n\
	sudo apt update\n\
	echo 'Installing Apache2...'\n\
	sudo apt install apache2 -y\n\
	echo 'Starting Apache2...'\n\
	sudo systemctl start apache2\n\
	echo 'Enabling Apache2 to start on boot...'\n\
	sudo systemctl enable apache2\n\
	# Copy your website files\n\
	echo 'Removing old website files...'\n\
	sudo rm -rf $(APACHE_DIR)/*\n\
	echo 'Copying new website files to $(APACHE_DIR)...'\n\
	sudo cp -r $(WEBSITE_SRC)/* $(APACHE_DIR)/\n\
	# Set correct ownership and permissions\n\
	echo 'Setting ownership and permissions...'\n\
	sudo chown -R www-data:www-data $(APACHE_DIR)\n\
	sudo chmod -R 755 $(APACHE_DIR)\n\
	echo 'Apache2 reinstall and website setup complete!'" > setup_apache.sh
	@chmod +x setup_apache.sh
	@./setup_apache.sh
	@rm setup_apache.sh

# Step 2: Build the Docker image
build-docker:
	@echo "Building Docker image..."
	docker build -t $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) .

# Step 3: Push the Docker image to Docker Hub
push-docker:
	@echo "Pushing Docker image to Docker Hub..."
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)

# Step 4: Run the Docker container
run-docker:
	@echo "Running Docker container..."
	docker run -d -p 8888:80 $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)

# Step 5: Kubernetes Deployment
deploy-k8s:
	@echo "Deploying application to Kubernetes..."
	kubectl apply -f deployment.yaml
	kubectl apply -f service.yaml

# Step 6: Expose service with NodePort (if not exposed)
expose-k8s:
	@echo "Exposing service with NodePort..."
	kubectl expose deployment $(K8S_DEPLOYMENT_NAME) --type=NodePort --name=$(K8S_SERVICE_NAME) --port=80 --target-port=80 --node-port=$(NODE_PORT)

# Step 7: Clean up all Docker containers
clean-docker-containers:
	@echo "Forcefully removing all Docker containers..."
	docker rm -f $(docker ps -a -q)

# All steps in sequence
all: install-apache build-docker push-docker run-docker deploy-k8s expose-k8s

