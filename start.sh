#!/bin/bash
echo "🚀 Codestral-Mamba 起動中..."

read -p "💡 Hugging Face Token (Enterでスキップ): " HF_TOKEN
export HF_TOKEN=${HF_TOKEN:-""}

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
echo "📁 作業ディレクトリ: $TEMP_DIR"

curl -sL -o Dockerfile https://raw.githubusercontent.com/あなたのユーザー名/あなたのリポジトリ名/main/Dockerfile
curl -sL -o run.py https://raw.githubusercontent.com/あなたのユーザー名/あなたのリポジトリ名/main/run.py

BUILD_ARGS=""
if [ -n "$HF_TOKEN" ]; then
    BUILD_ARGS="--build-arg HF_TOKEN=$HF_TOKEN"
fi

echo "🐳 ビルド中..."
docker build $BUILD_ARGS -t codestral-local .

echo "🔥 起動中..."
docker run --gpus all -p 8000:8000 -p 7860:7860 --rm codestral-local