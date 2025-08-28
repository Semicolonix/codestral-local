# runtime イメージを使用（nvcc なし）
FROM pytorch/pytorch:2.8.0-cuda12.9-cudnn9-runtime

# Hugging Face Token をビルド時に受け取る
ARG HF_TOKEN
ENV HF_TOKEN=$HF_TOKEN

# 必要なシステムパッケージをインストール
RUN apt-get update && apt-get install -y \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# pip を最新化
RUN pip install --upgrade pip

# 🔑 重要：numpy を先にインストール（mamba-ssm の依存関係のため）
RUN pip install numpy

# mamba-ssm の事前ビルド済みwheelを優先してインストール
# CUDA 12.1 用のバイナリが CUDA 12.9 でも動作します
RUN pip install mamba-ssm[causal-conv1d]>=2.2.0 -f https://smittytone.net/mamba-wheels/

# 他のパッケージをインストール
RUN pip install \
    transformers accelerate \
    fastapi uvicorn gradio \
    sentencepiece \
    psutil requests

WORKDIR /app
COPY run.py /app/run.py

EXPOSE 8000 7860

CMD ["python", "run.py"]