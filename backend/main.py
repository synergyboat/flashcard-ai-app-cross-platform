from fastapi import FastAPI
from api.routes.router import router
app = FastAPI()
app.include_router(router)
