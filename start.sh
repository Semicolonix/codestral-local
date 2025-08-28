#!/bin/bash
echo "🚀 Codestral-Mamba 起動中..."

read -p "💡 Hugging Face Token を入力（codestralアクセス用、Enterでスキップ）: " HF_TOKEN
export HF_TOKEN=${HF_TOKEN:-""}

# 一時ディレクトリ作成
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
echo "📁 一時作業ディレクトリ: $TEMP_DIR"

# ファイルをダウンロード
echo "⏬ 必要ファイルをダウンロード中..."
curl -sL -o Dockerfile https://raw.githubusercontent.com/Semicolonix/codestral-local/main/Dockerfile
curl -sL -o run.py https://raw.githubusercontent.com/Semicolonix/codestral-local/main/run.py

# Dockerイメージのビルド（明示的にパスを指定）
echo "🐳 Dockerイメージをビルド中..."
docker build --progress=plain \
  --build-arg HF_TOKEN="$HF_TOKEN" \
  -t codestral-local \
  "$TEMP_DIR" || {
  echo "❌ ビルド失敗。Docker Desktopが起動しているか確認してください。"
  exit 1
}

# コンテナの実行
echo "🔥 コンテナを起動中..."
docker run --gpus all -p 8000:8000 -p 7860:7860 --rm codestral-local