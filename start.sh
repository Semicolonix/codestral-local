#!/bin/bash
# start.sh - Codestral-Mamba 1コマンド起動スクリプト

set -euo pipefail

echo "🚀 Codestral-Mamba 起動スクリプト"
echo "⏳ すべて自動でセットアップします..."

# Hugging Face Tokenの入力（任意）
read -p "💡 Hugging Face Tokenを入力（codestralアクセス用、Enterでスキップ）: " HF_TOKEN
export HF_TOKEN=${HF_TOKEN:-""}

# 一時作業ディレクトリ
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
echo "📁 作業ディレクトリ: $TEMP_DIR"

# 必要ファイルをダウンロード
echo "⏬ ファイルをダウンロード中..."
curl -sL -o Dockerfile https://raw.githubusercontent.com/yourname/yourrepo/main/Dockerfile
curl -sL -o run.py https://raw.githubusercontent.com/yourname/yourrepo/main/run.py

# HF_TOKENをビルド時に渡す（オプション）
BUILD_ARGS=""
if [ -n "$HF_TOKEN" ]; then
    BUILD_ARGS="--build-arg HF_TOKEN=$HF_TOKEN"
fi

# Dockerイメージをビルド
echo "🐳 Dockerイメージをビルド中..."
docker build $BUILD_ARGS -t codestral-local .

# 実行
echo "🔥 コンテナを起動中..."
docker run --gpus all -p 8000:8000 -p 7860:7860 --rm codestral-local

echo "✅ 終了しました。"