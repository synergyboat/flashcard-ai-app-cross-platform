import os
import shutil
import tempfile
from typing import IO
from common.validators.file_validator import validate_file_size, validate_file_mime, validate_file_extension
from domain.interfaces.file_repository_interface import IFileRepositoryInterface

class LocalFileRepositoryImpl(IFileRepositoryInterface):
    def save(self, file_stream: IO[bytes], filename: str) -> str:
        validate_file_extension(filename)

        suffix = os.path.splitext(filename)[1]
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            # tmp.file is IO[bytes] which has a write method. So, ignore the type hinting error.
            shutil.copyfileobj(file_stream, tmp.file)  # type: ignore
            tmp_path = tmp.name

        validate_file_mime(tmp_path)
        validate_file_size(tmp_path)
        return tmp_path

    def delete(self, path: str) -> None:
        if os.path.exists(path):
            os.remove(path)
