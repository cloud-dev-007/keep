from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def index():
    return {"details" : "Backend is running designed By Demilade"}