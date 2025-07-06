import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import httpx

DEEPL_API_KEY = os.environ.get('DEEPL_API_KEY')
if not DEEPL_API_KEY:
    raise RuntimeError("DEEPL_API_KEY is not set in environment variables.")

DEEPL_API_URL = "https://api-free.deepl.com/v2/translate"

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class TranslationRequest(BaseModel):
    text: str
    target_lang: str
    source_lang: str = None

@app.post("/translate")
async def translate(req: TranslationRequest):
    payload = {
        "text": req.text,
        "target_lang": req.target_lang,
    }
    if req.source_lang and req.source_lang != "auto":
        payload["source_lang"] = req.source_lang

    headers = {
        "Authorization": f"DeepL-Auth-Key {DEEPL_API_KEY}",
        "Content-Type": "application/x-www-form-urlencoded",
    }

    async with httpx.AsyncClient() as client:
        try:
            resp = await client.post(DEEPL_API_URL, data=payload, headers=headers, timeout=15.0)
            resp.raise_for_status()
            data = resp.json()
            translations = data.get("translations", [])
            # DeepL APIの翻訳文は配列。全件を連結して返す
            texts = [item.get("text", "") for item in translations]
            return {"text": "\n".join(texts)}
        except httpx.HTTPStatusError as e:
            raise HTTPException(status_code=resp.status_code, detail=resp.text)
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
