# Apache Spark & JupyterLab Big Data Stack

This stack provides a complete, distributed Apache Spark cluster (Master + Worker) paired with a JupyterLab environment preconfigured with PySpark.

## Components
- **Spark Master**: Manages resource allocation and coordinates execution (`http://spark.apps.local:8080`).
- **Spark Worker**: Executes data processing tasks.
- **JupyterLab**: Interactive notebook environment preconfigured with PySpark (`http://jupyter.apps.local:8888`, token: `secret`).

## Usage

```bash
docker compose up -d
```
