#!/bin/bash

# Variables
APP_CHART_DIR="../app-stack"                  # Replace with the path to your parent chart
RELEASE_NAME="gnx-app-stack"                  # Replace with your desired release name
MONGODB_VALUES_FILE="./mongodb-values.yaml"   # Path to your MongoDB custom values file
RABBITMQ_VALUES_FILE="./rabbitmq-values.yaml" # Path to your RabbitMQ custom values file

# Check if the MongoDB values file exists
if [[ ! -f "$MONGODB_VALUES_FILE" ]]; then
    echo "Custom values file $MONGODB_VALUES_FILE not found!"
    exit 1
fi

# Check if the RABBITMQ values file exists
if [[ ! -f "$RABBITMQ_VALUES_FILE" ]]; then
    echo "Custom values file $RABBITMQ_VALUES_FILE not found!"
    exit 1
fi

# Update Helm repo (optional)
echo "Updating Helm repositories..."
helm repo update


# Install/Update Helm Rabbitmq repo 
echo "Updating/Installing RabbitMQ service..."
helm upgrade --install rabbitmq -f rabbitmq-values.yaml oci://registry-1.docker.io/bitnamicharts/rabbitmq -n rabbitmq --create-namespace
echo "Updating/Installing RabbitMQ service completed..."
echo "----------------------------------------------------"
# Install/Update Helm Mongodb repo 
echo "Udating/Installing Mongodb service..."
helm upgrade --install mongodb -f mongodb-values.yaml oci://registry-1.docker.io/bitnamicharts/mongodb -n mongodb --create-namespace
echo "Updating/Installing Mongodb service completed..."
echo "----------------------------------------------------"

# Install/Update Backend services repo 
echo "build dependency..."
helm dependency build .
echo "----------------------------------------------------"

echo "build dependency list..."
helm dependency list
echo "----------------------------------------------------"

# Delay for 10 seconds to allow Helm to process the install/upgrade
echo "Waiting for 30 seconds for the installation to stabilize..."
sleep 30

# Verify the installation
echo "Verifying the installation..."
kubectl get pods --namespace mongodb
kubectl get pods --namespace rabbitmq

