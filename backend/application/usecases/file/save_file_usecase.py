from typing import IO

from domain.interfaces.file_repository_interface import IFileRepositoryInterface


class SaveMediaUseCase:
    def __init__(self, file_storage_repository: IFileRepositoryInterface):
        self.file_storage_repository = file_storage_repository

    def execute(self, media_file: IO[bytes], filename: str) -> str:
        """
        Uploads a media file using the provided media repository.

        :param filename:
        :param media_file: The media file to be uploaded.
        :return: The result of the upload operation.
        """
        return self.file_storage_repository.save(media_file, filename)