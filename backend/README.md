# Contract Guardian Backend

This folder contains the v2 backend for Contract Guardian.

## Stack

- FastAPI
- Pydantic
- Pydantic Settings
- Uvicorn
- Docker
- Railway / Render ready config

## Run locally

```powershell
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Local endpoints

- `GET /`
- `GET /health`
- `POST /api/v1/analyze`

## Railway deployment

Railway supports Dockerfile deployments and config-as-code. Official docs note that:

- Dockerfile services should listen on Railway's injected `PORT` variable.
- Monorepos can use a root directory, but the Railway config file path may need to be set explicitly, for example `/backend/railway.toml`.
- Healthchecks should return HTTP 200, which this backend does on `/health`.

### Recommended Railway setup

1. Push this repo to GitHub.
2. Create a new Railway project from the repo.
3. Create a service from the repo.
4. Set the service root directory to `backend`.
5. If Railway does not auto-detect the config file, set the config path to `/backend/railway.toml`.
6. Add environment variables from `.env.example`.
7. Set `CONTRACT_GUARDIAN_DEBUG=false` in production.
8. Generate a public Railway domain from the service Networking settings.

### Production environment variables

At minimum:

- `CONTRACT_GUARDIAN_ENV=production`
- `CONTRACT_GUARDIAN_DEBUG=false`
- `CONTRACT_GUARDIAN_ALLOWED_ORIGINS=https://your-frontend-domain`

## Render deployment

1. Push the repo to GitHub.
2. Create a new Web Service in Render.
3. Choose Docker runtime.
4. Set the root directory to `backend`.
5. Optionally use `render.yaml`.
6. Add environment variables from `.env.example`.

## Production shape

Layers:

- `app/core`: config, logging, and error handling
- `app/api`: FastAPI routes
- `app/domain`: reusable analysis rules
- `app/services`: orchestration and scoring
- `app/schemas`: typed request and response models

Current backend behavior:

- accepts contract text plus source metadata
- scores findings and returns a verdict
- returns a generated summary and negotiation scripts
- supports CORS for local Flutter and web development
- adds request timing headers and server logging
- returns structured error responses for validation and server failures

## Next upgrades

- PostgreSQL database
- file upload and object storage
- OCR services
- LLM-based clause reasoning
- RAG-backed legal knowledge
- auth and billing
