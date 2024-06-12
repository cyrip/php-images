# Define variables
IMAGE_NAME = cyrip/php
TAG = 8.3-swoole-alpine

# Default target
.PHONY: all
all: build

# Build the Docker image
.PHONY: build
build:
	@echo "Building Docker image $(IMAGE_NAME):$(TAG)..."
	docker buildx build -t $(IMAGE_NAME):$(TAG) .
	docker push $(IMAGE_NAME):$(TAG)

# Clean target (optional, can be used to remove the image)
.PHONY: clean
clean:
	@echo "Removing Docker image $(IMAGE_NAME):$(TAG)..."
	docker rmi $(IMAGE_NAME):$(TAG)

# Run target (optional, can be used to run the built image)
.PHONY: run
run:
	@echo "Running Docker container from image $(IMAGE_NAME):$(TAG)..."
	docker run -it -p 8000:8000 $(IMAGE_NAME):$(TAG)
