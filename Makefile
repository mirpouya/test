.PHONY: build run enter stop rm clean status

IM_NAME=orb3-realsense-dev
CONT_NAME=orb3-realsense-container
HOST_PATH=$(shell pwd)
CONTAINER_PATH=/workspace/ORB_SLAM3

# Default target
default: build run

# Build Docker image
build:
	@echo "Building Docker image: $(IM_NAME)"
	sudo docker build --no-cache -t $(IM_NAME) .

run:
	@echo "Running Docker container: $(CONT_NAME)"
	sudo xhost +local:root
	@if [ -n "$$(docker ps -aqf name=$(CONT_NAME))" ]; then \
		echo "Container $(CONT_NAME) already exists. Starting it..."; \
		sudo docker start -ai $(CONT_NAME); \
	else \
		sudo docker run --gpus all -it -d --privileged \
			--device=/dev/bus/usb \
			-v /dev:/dev \
			-e DISPLAY=$$DISPLAY \
			-e QT_X11_NO_MITSHM=1 \
			-v /tmp/.X11-unix:/tmp/.X11-unix \
			-v $$HOME/.Xauthority:/root/.Xauthority \
			-v $(HOST_PATH):$(CONTAINER_PATH) \
			--name $(CONT_NAME) $(IM_NAME); \
		echo "Container $(CONT_NAME) started."; \
	fi


# Enter the running container
enter:
	sudo docker exec -it $(CONT_NAME) bash

# Stop the container
stop:
	@echo "Stopping container: $(CONT_NAME)"
	-sudo docker stop $(CONT_NAME)

# Remove the container
rm:
	@echo "Removing container: $(CONT_NAME)"
	-sudo docker rm $(CONT_NAME)

# Stop and remove the container
clean:
	$(MAKE) stop
	$(MAKE) rm

# Show Docker container and image status
status:
	@echo "Docker Containers:"
	@docker ps -a | grep $(CONT_NAME) || echo "No container named $(CONT_NAME) found."
	@echo "\nDocker Images:"
	@docker images | grep $(IM_NAME) || echo "No image named $(IM_NAME) found."