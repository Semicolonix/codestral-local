import os
import time
import threading
import requests
from fastapi import FastAPI
from pydantic import BaseModel
from transformers import AutoTokenizer, AutoModelForCausalLM
import uvicorn
import gradio as gr

MODEL_ID = "mistralai/codestral-mamba-7b-v0.1"
API_HOST = "127.0.0.1"
API_PORT = 8000
UI_PORT = 7860
HF_TOKEN = os.getenv("HF_TOKEN")

print(f"⏬ モデルをロード中: {MODEL_ID}")

try:
    tokenizer = AutoTokenizer.from_pretrained(MODEL_ID, token=HF_TOKEN)
    model = AutoModelForCausalLM.from_pretrained(
        MODEL_ID,
        device_map="auto",
        torch_dtype="auto",
        token=HF_TOKEN
    )
    print("✅ ロード完了")
except Exception as e:
    print(f"❌ 失敗: {e}")
    exit(1)

app = FastAPI()

class GenerateRequest(BaseModel):
    prompt: str
    max_tokens: int = 128

@app.post("/generate")
def generate(req: GenerateRequest):
    try:
        inputs = tokenizer(req.prompt, return_tensors="pt").to(model.device)
        outputs = model.generate(
            **inputs,
            max_new_tokens=req.max_tokens,
            do_sample=True,
            temperature=0.7,
            top_p=0.95
        )
        response = tokenizer.decode(outputs[0], skip_special_tokens=True)
        return {"response": response[len(req.prompt):]}
    except Exception as e:
        return {"error": str(e)}

def start_api():
    uvicorn.run(app, host=API_HOST, port=API_PORT, log_level="warning")

def chat(message, history):
    try:
        res = requests.post(f"http://{API_HOST}:{API_PORT}/generate", json={"prompt": message})
        return res.json().get("response", "エラー")
    except:
        return "接続エラー"

def start_ui():
    time.sleep(5)
    demo = gr.ChatInterface(
        fn=chat,
        title="🧠 Codestral-Mamba - ローカルAIコーダー",
        description="コード生成・説明・デバッグ支援",
        examples=[
            "PythonでCSV読み込み関数を書いて",
            "Reactのカウンターを作って",
            "def add(a, b): return a - b にバグを直して"
        ]
    )
    demo.launch(server_name="0.0.0.0", server_port=UI_PORT, share=False)

if __name__ == "__main__":
    from threading import Thread
    Thread(target=start_api, daemon=True).start()
    start_ui()