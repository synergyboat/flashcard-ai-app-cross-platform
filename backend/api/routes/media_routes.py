from fastapi import APIRouter

media_router = APIRouter(prefix="/media")


@media_router.get("/{media_id}")
async def get_media(media_id: str):
    """
    Retrieve media by ID.
    Args:
        media_id (str): The ID of the media to retrieve.
    Returns:
        Not implemented yet.
    Raises:
        NotImplementedError: This function is not yet implemented.
    """
    return {"media_id": media_id, "message": "Media retrieved successfully"}