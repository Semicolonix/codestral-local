# Dockerfile
FROM pytorch/pytorch:2.8.0-cuda12.9-cudnn9-runtime

# 基本ツールとライブラリをインストール
RUN apt-get update && apt-get install -y \
    python3-pip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 必要なPythonパッケージをインストール
RUN pip install --upgrade pip
RUN pip install \
    transformers accelerate \
    fastapi uvicorn gradio \
    mamba-ssm causal-conv1d>=1.2.0 sentencepiece \
    psutil requests torch

# アプリ用ディレクトリ
WORKDIR /app

# モデルキャッシュ用ボリューム（任意）
ENV TRANSFORMERS_CACHE="/app/.cache"

# run.pyをコピー
COPY run.py /app/run.py

# ポート開放
EXPOSE 8000 7860

# 起動コマンド
CMD ["python", "run.py"]