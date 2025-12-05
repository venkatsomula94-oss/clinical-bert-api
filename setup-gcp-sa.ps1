# Script to create GCP Service Account for GitHub Actions
# Project: hale-ivy-480308-q0

# 1. Create service account
Write-Host "Creating service account..." -ForegroundColor Green
gcloud iam service-accounts create github-actions `
  --display-name="GitHub Actions Service Account" `
  --project=hale-ivy-480308-q0

# 2. Grant Cloud Run Admin role
Write-Host "Granting Cloud Run Admin role..." -ForegroundColor Green
gcloud projects add-iam-policy-binding hale-ivy-480308-q0 `
  --member="serviceAccount:github-actions@hale-ivy-480308-q0.iam.gserviceaccount.com" `
  --role="roles/run.admin"

# 3. Grant Artifact Registry Writer role
Write-Host "Granting Artifact Registry Writer role..." -ForegroundColor Green
gcloud projects add-iam-policy-binding hale-ivy-480308-q0 `
  --member="serviceAccount:github-actions@hale-ivy-480308-q0.iam.gserviceaccount.com" `
  --role="roles/artifactregistry.writer"

# 4. Grant Service Account User role
Write-Host "Granting Service Account User role..." -ForegroundColor Green
gcloud projects add-iam-policy-binding hale-ivy-480308-q0 `
  --member="serviceAccount:github-actions@hale-ivy-480308-q0.iam.gserviceaccount.com" `
  --role="roles/iam.serviceAccountUser"

# 5. Create and download the key
Write-Host "Creating service account key..." -ForegroundColor Green
gcloud iam service-accounts keys create github-actions-key.json `
  --iam-account=github-actions@hale-ivy-480308-q0.iam.gserviceaccount.com `
  --project=hale-ivy-480308-q0

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Service Account Key Created!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nFile: github-actions-key.json"
Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Open github-actions-key.json"
Write-Host "2. Copy the ENTIRE contents (it's a JSON object)"
Write-Host "3. Go to GitHub: Settings -> Secrets and variables -> Actions"
Write-Host "4. Create new secret: GCP_SA_KEY"
Write-Host "5. Paste the JSON content as the value"
Write-Host "6. Also create secret: GCP_PROJECT_ID = hale-ivy-480308-q0"
Write-Host "`nWARNING: Keep this key file secure and delete it after adding to GitHub!" -ForegroundColor Red
