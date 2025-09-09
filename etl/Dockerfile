FROM python:3.11-slim

WORKDIR /app

# Instalar git y dependencias
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Instalar dependencias Python
RUN pip install --no-cache-dir \
    requests \
    chromadb \
    gitpython \
    python-magic \
    chardet

COPY etl.py /app/etl.py

ENTRYPOINT ["python", "etl.py"]
