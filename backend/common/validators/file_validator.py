import os
import filetype
from fastapi import HTTPException

ALLOWED_FILE_EXTENSIONS = {".pdf", ".docx", ".txt"}
MAX_FILE_SIZE_MB = 10

def validate_file_extension(filename: str):
    _, ext = os.path.splitext(filename)
    if ext.lower() not in ALLOWED_FILE_EXTENSIONS:
        raise HTTPException(status_code=400, detail="Unsupported file type")


def validate_file_mime(path: str):
    kind = filetype.guess(path)
    if not kind or not kind.mime.startswith(("application/", "text/")):
        raise HTTPException(status_code=400, detail="Disallowed MIME type")


def validate_file_size(path: str):
    size_mb = os.path.getsize(path) / (1024 * 1024)
    if size_mb > MAX_FILE_SIZE_MB:
        os.remove(path)
        raise HTTPException(status_code=400, detail="File too large")
