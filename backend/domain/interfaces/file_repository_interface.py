from abc import ABC, abstractmethod
from typing import IO

class IFileRepositoryInterface(ABC):
    @abstractmethod
    def save(self, file_stream: IO[bytes], filename: str) -> str:
        """
        Save a file stream with original filename. Returns temp path.
        :param file_stream: The file stream to be saved.
        :param filename: The original filename.
        :return: The path where the file is saved.
        """
        pass

    @abstractmethod
    def delete(self, path: str) -> None:
        """
        Delete the file at the given path.
        :param path: The path of the file to be deleted.
        :return: None
        """
        pass
