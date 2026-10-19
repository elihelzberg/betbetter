# server.py
import jaclang  # Enables Python to import .jac files directly!

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional

# Import Jac functions and models
from endpoints import list_games, game_history, ask_question
from models import Query

app = FastAPI(title="betBetter Mobile API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class QuestionPayload(BaseModel):
    question: str

@app.post("/api/games")
def api_list_games(query: Query):
    try:
        return list_games(query)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/games/{game_id}/history")
def api_game_history(game_id: str, state: str = "MI"):
    try:
        return game_history(game_id=game_id, state=state)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/api/ask")
def api_ask_question(payload: QuestionPayload):
    try:
        return ask_question(payload.question)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)