#!/bin/bash

# Clinical Assertion Classification API - GCP Deployment Script
# This script deploys the Docker container to Google Cloud Run

set -e

# Configuration
PROJECT_ID="${GCP_PROJECT_ID:-your-gcp-project-id}"
SERVICE_NAME="clinical-bert-api"
REGION="${GCP_REGION:-us-central1}"
REGISTRY="us-central1-docker.pkg.dev"
REPOSITORY_NAME="clinical-bert-api"

echo "=========================================="
echo "Clinical BERT API - GCP Deployment"
echo "=========================================="
echo "Project ID: $PROJECT_ID"
echo "Service Name: $SERVICE_NAME"
echo "Region: $REGION"
echo "=========================================="

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI is not installed."
    echo "Please install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Authenticate (if needed)
echo "Step 1: Authenticating with GCP..."
gcloud auth login --brief

# Set project
echo "Step 2: Setting GCP project..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "Step 3: Enabling required GCP APIs..."
gcloud services enable \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    artifactregistry.googleapis.com

# Create Artifact Registry repository (if it doesn't exist)
echo "Step 4: Creating Artifact Registry repository..."
gcloud artifacts repositories create $REPOSITORY_NAME \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository for Clinical BERT API" \
    2>/dev/null || echo "Repository already exists, continuing..."

# Configure Docker authentication
echo "Step 5: Configuring Docker authentication..."
gcloud auth configure-docker $REGISTRY

# Build the Docker image
echo "Step 6: Building Docker image..."
IMAGE_NAME="$REGISTRY/$PROJECT_ID/$REPOSITORY_NAME/$SERVICE_NAME:latest"
docker build -t $IMAGE_NAME .

# Push to Artifact Registry
echo "Step 7: Pushing image to Artifact Registry..."
docker push $IMAGE_NAME

# Deploy to Cloud Run
echo "Step 8: Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image=$IMAGE_NAME \
    --platform=managed \
    --region=$REGION \
    --allow-unauthenticated \
    --memory=2Gi \
    --cpu=2 \
    --timeout=300 \
    --max-instances=10 \
    --min-instances=0 \
    --port=8080 \
    --set-env-vars="PYTHONUNBUFFERED=1"

# Get the service URL
echo "Step 9: Retrieving service URL..."
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
    --region=$REGION \
    --format='value(status.url)')

echo "=========================================="
echo "Deployment Complete! 🚀"
echo "=========================================="
echo "Service URL: $SERVICE_URL"
echo ""
echo "Test the API:"
echo "  Health Check: curl $SERVICE_URL/health"
echo "  Prediction: curl -X POST $SERVICE_URL/predict \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"sentence\": \"The patient denies chest pain.\"}'"
echo ""
echo "API Documentation: $SERVICE_URL/docs"
echo "=========================================="
