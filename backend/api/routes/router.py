from fastapi import APIRouter

from .auth_routes import auth_routes
from .flashcard_routes import flashcard_routes
from .media_routes import media_router

router = APIRouter(prefix="/api", tags=["api"])

router.include_router(media_router)
router.include_router(auth_routes)
router.include_router(flashcard_routes)