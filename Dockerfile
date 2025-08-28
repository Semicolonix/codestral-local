FROM pytorch/pytorch:2.8.0-cuda12.9-cudnn9-runtime

RUN apt-get update && apt-get install -y \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
RUN pip install \
    transformers accelerate \
    fastapi uvicorn gradio \
    mamba-ssm causal-conv1d>=1.2.0 sentencepiece \
    psutil requests torch

WORKDIR /app
COPY run.py /app/run.py

EXPOSE 8000 7860

CMD ["python", "run.py"]