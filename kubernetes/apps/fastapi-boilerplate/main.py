import os
from fastapi import FastAPI

app = FastAPI(
    title=os.getenv("APP_NAME", "Cloud-Native FastAPI"),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

@app.get("/")
def read_root():
    return {
        "status": "ok",
        "app_name": os.getenv("APP_NAME", "Cloud-Native FastAPI"),
        "environment": os.getenv("ENVIRONMENT", "unknown"),
        "debug": os.getenv("DEBUG", "false"),
    }

@app.get("/healthz")
def healthz():
    return {"status": "healthy"}
