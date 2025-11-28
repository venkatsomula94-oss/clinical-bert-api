# Development
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload

# Testing
pytest tests/ -v
python example_usage.py

# Docker
docker build -t clinical-bert-api .
docker run -p 8080:8080 clinical-bert-api

# GCP Deployment
export GCP_PROJECT_ID="your-project-id"
./deploy.sh

# Manual GCP Deployment
gcloud builds submit --tag us-central1-docker.pkg.dev/PROJECT_ID/clinical-bert-api/clinical-bert-api:latest
gcloud run deploy clinical-bert-api \
  --image=us-central1-docker.pkg.dev/PROJECT_ID/clinical-bert-api/clinical-bert-api:latest \
  --platform=managed \
  --region=us-central1 \
  --allow-unauthenticated \
  --memory=2Gi \
  --cpu=2
