# Clinical Assertion Classification API

A production-ready FastAPI service that classifies clinical assertion status (PRESENT, ABSENT, CONDITIONAL) in medical text using the Hugging Face model `bvanaken/clinical-assertion-negation-bert`.

## 🎯 Overview

Healthcare systems contain unstructured clinical notes where understanding the assertion status of medical concepts is critical for diagnostics and analytics. This API provides real-time classification with confidence scores to support clinical decision-making.

## ✨ Features

- **FastAPI Framework**: High-performance async API with automatic OpenAPI documentation
- **Model Caching**: Loads model once at startup for optimal performance
- **Batch Processing**: Support for single and batch predictions
- **Health Checks**: Built-in health endpoint for monitoring
- **Docker Support**: Containerized deployment using Python 3.12-slim
- **CI/CD Pipeline**: Automated testing and deployment with GitHub Actions
- **Cloud Ready**: Optimized for Google Cloud Run deployment
- **Performance**: < 500ms response time for short clinical sentences

## 📋 Requirements

- Python 3.12+
- Docker (for containerization)
- Google Cloud SDK (for GCP deployment)
- 2GB RAM minimum (for model loading)

## 🚀 Quick Start

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/clinical-bert-api.git
   cd clinical-bert-api
   ```

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload
   ```

5. **Access the API**
   - API: http://localhost:8080
   - Interactive docs: http://localhost:8080/docs
   - Health check: http://localhost:8080/health

### Docker Deployment

1. **Build the Docker image**
   ```bash
   docker build -t clinical-bert-api .
   ```

2. **Run the container**
   ```bash
   docker run -p 8080:8080 clinical-bert-api
   ```

3. **Access the API at http://localhost:8080**

## 🌐 API Endpoints

### POST /predict
Classify a single clinical sentence.

**Request:**
```json
{
  "sentence": "The patient denies chest pain."
}
```

**Response:**
```json
{
  "label": "ABSENT",
  "score": 0.9842
}
```

### POST /predict/batch
Classify multiple clinical sentences at once.

**Request:**
```json
{
  "sentences": [
    "The patient denies chest pain.",
    "He has a history of hypertension."
  ]
}
```

**Response:**
```json
{
  "predictions": [
    {
      "label": "ABSENT",
      "score": 0.9842
    },
    {
      "label": "PRESENT",
      "score": 0.9756
    }
  ]
}
```

### GET /health
Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "model_loaded": true,
  "model_name": "bvanaken/clinical-assertion-negation-bert"
}
```

## 📝 Example Usage

### Python

```python
import requests

# API endpoint
API_URL = "http://localhost:8080"

# Single prediction
response = requests.post(
    f"{API_URL}/predict",
    json={"sentence": "The patient denies chest pain."}
)
result = response.json()
print(f"Label: {result['label']}, Score: {result['score']}")

# Batch prediction
response = requests.post(
    f"{API_URL}/predict/batch",
    json={
        "sentences": [
            "The patient denies chest pain.",
            "He has a history of hypertension.",
            "If the patient experiences dizziness, reduce the dosage.",
            "No signs of pneumonia were observed."
        ]
    }
)
results = response.json()
for i, pred in enumerate(results['predictions']):
    print(f"Sentence {i+1}: {pred['label']} (score: {pred['score']})")
```

### cURL

```bash
# Health check
curl http://localhost:8080/health

# Single prediction
curl -X POST http://localhost:8080/predict \
  -H "Content-Type: application/json" \
  -d '{"sentence": "The patient denies chest pain."}'

# Batch prediction
curl -X POST http://localhost:8080/predict/batch \
  -H "Content-Type: application/json" \
  -d '{
    "sentences": [
      "The patient denies chest pain.",
      "He has a history of hypertension."
    ]
  }'
```

## ☁️ Cloud Deployment (GCP)

### Prerequisites

1. **Google Cloud Account** with $300 free credits for new users
2. **Install Google Cloud SDK**
   ```bash
   # Download from https://cloud.google.com/sdk/docs/install
   gcloud init
   ```

3. **Set up authentication**
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

### Deployment Steps

#### Option 1: Using the deployment script

1. **Set environment variables**
   ```bash
   export GCP_PROJECT_ID="your-project-id"
   export GCP_REGION="us-central1"
   ```

2. **Run the deployment script**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

#### Option 2: Manual deployment

1. **Enable required APIs**
   ```bash
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable run.googleapis.com
   gcloud services enable artifactregistry.googleapis.com
   ```

2. **Create Artifact Registry repository**
   ```bash
   gcloud artifacts repositories create clinical-bert-api \
     --repository-format=docker \
     --location=us-central1 \
     --description="Clinical BERT API"
   ```

3. **Build and push Docker image**
   ```bash
   gcloud builds submit --tag us-central1-docker.pkg.dev/YOUR_PROJECT_ID/clinical-bert-api/clinical-bert-api:latest
   ```

4. **Deploy to Cloud Run**
   ```bash
   gcloud run deploy clinical-bert-api \
     --image=us-central1-docker.pkg.dev/YOUR_PROJECT_ID/clinical-bert-api/clinical-bert-api:latest \
     --platform=managed \
     --region=us-central1 \
     --allow-unauthenticated \
     --memory=2Gi \
     --cpu=2 \
     --timeout=300 \
     --max-instances=10
   ```

5. **Get the service URL**
   ```bash
   gcloud run services describe clinical-bert-api \
     --region=us-central1 \
     --format='value(status.url)'
   ```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflows

#### Continuous Integration (ci.yml)
Triggers on pull requests and pushes to `main` and `develop` branches.

**Steps:**
- Install dependencies
- Run flake8 linting
- Run black formatting checks
- Execute pytest test suite
- Build Docker image
- Security vulnerability scanning with Trivy

#### Continuous Deployment (cd.yml)
Triggers on pushes to `main` branch and version tags.

**Steps:**
- Authenticate with GCP
- Build Docker image
- Push to Artifact Registry
- Deploy to Cloud Run
- Run health check
- Create deployment summary

### Setup GitHub Secrets

Add these secrets to your GitHub repository:

1. **GCP_PROJECT_ID**: Your Google Cloud project ID
2. **GCP_SA_KEY**: Service account JSON key with required permissions

**Creating a service account:**
```bash
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.admin"

gcloud iam service-accounts keys create key.json \
  --iam-account=github-actions@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

Copy the contents of `key.json` to the `GCP_SA_KEY` secret.

## 🧪 Testing

### Run tests locally

```bash
# Install test dependencies
pip install -r requirements.txt

# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=app --cov-report=html

# Run specific test class
pytest tests/test_api.py::TestPredictionEndpoint -v
```

### Test Cases

| Sentence | Expected Label |
|----------|----------------|
| "The patient denies chest pain." | ABSENT |
| "He has a history of hypertension." | PRESENT |
| "If the patient experiences dizziness, reduce the dosage." | CONDITIONAL |
| "No signs of pneumonia were observed." | ABSENT |

## 📁 Project Structure

```
clinical-bert-api/
├── app/
│   ├── __init__.py          # Package initialization
│   ├── main.py              # FastAPI application
│   ├── model.py             # Model loading & prediction logic
│   └── schemas.py           # Pydantic schemas for validation
├── tests/
│   ├── __init__.py          # Test package initialization
│   └── test_api.py          # API test cases
├── .github/
│   └── workflows/
│       ├── ci.yml           # Continuous Integration workflow
│       └── cd.yml           # Continuous Deployment workflow
├── Dockerfile               # Docker container definition
├── requirements.txt         # Python dependencies
├── .dockerignore           # Docker ignore rules
├── .gitignore              # Git ignore rules
├── deploy.sh               # GCP deployment script
└── README.md               # This file
```

## ⚙️ Configuration

### Environment Variables

- `PYTHONUNBUFFERED=1`: Ensure logs are flushed immediately
- `PORT`: Server port (default: 8080)

### Model Configuration

- **Model**: `bvanaken/clinical-assertion-negation-bert`
- **Framework**: Hugging Face Transformers
- **Device**: Automatically detects CUDA GPU or falls back to CPU
- **Max Tokens**: 512 (truncated if longer)

### Resource Requirements

- **Memory**: 2GB minimum (model loading + inference)
- **CPU**: 2 cores recommended for production
- **Storage**: ~500MB for model weights

## 🐛 Known Issues & Tradeoffs

### Known Issues

1. **Cold Start Time**: Initial request may take 10-30 seconds on Cloud Run due to model loading. Subsequent requests are fast.
   - **Mitigation**: Set `min-instances=1` in Cloud Run (increases cost)

2. **Large Model Size**: The BERT model is ~400MB, increasing Docker image size and build time.
   - **Tradeoff**: Accepted for better accuracy vs. smaller models

3. **CPU Inference**: Without GPU, inference takes 200-400ms per sentence.
   - **Mitigation**: Batch predictions are more efficient for multiple sentences

### Tradeoffs

1. **Model in Docker Image**: Pre-downloading the model in Dockerfile increases image size but eliminates download time at startup.

2. **Memory Allocation**: Using 2GB RAM ensures stable operation but may be overkill for CPU-only instances.

3. **Allow Unauthenticated**: Deployed without authentication for demo purposes. In production, implement proper authentication.

## 🔒 Security Considerations

For production deployment:

1. **Enable Authentication**: Remove `--allow-unauthenticated` flag
2. **Use IAM**: Implement proper service account roles
3. **API Keys**: Add API key authentication in FastAPI
4. **Rate Limiting**: Implement rate limiting to prevent abuse
5. **HTTPS Only**: Ensure all traffic is encrypted
6. **Input Validation**: Already implemented via Pydantic schemas
7. **Vulnerability Scanning**: Integrated Trivy scanner in CI pipeline

## 📊 Performance Metrics

- **Average Response Time**: 200-400ms (CPU), 50-100ms (GPU)
- **Model Load Time**: 5-10 seconds at startup
- **Memory Usage**: 1.5-2GB (including model weights)
- **Throughput**: ~5-10 requests/second (single instance)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Model**: [bvanaken/clinical-assertion-negation-bert](https://huggingface.co/bvanaken/clinical-assertion-negation-bert)
- **Framework**: [FastAPI](https://fastapi.tiangolo.com/)
- **Transformers**: [Hugging Face Transformers](https://huggingface.co/transformers/)

## 📧 Contact

For questions or issues, please open a GitHub issue or contact the maintainers.

---

**Built with ❤️ for healthcare AI applications**
