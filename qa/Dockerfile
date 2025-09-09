FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias
RUN pip install --no-cache-dir \
    fastapi \
    uvicorn \
    requests \
    chromadb \
    pydantic

COPY app.py /app/app.py

EXPOSE 5000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "5000"]
