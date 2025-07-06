from domain.interfaces.file_repository_interface import IFileRepositoryInterface


class DeleteMediaUseCase:
    def __init__(self, file_repository: IFileRepositoryInterface):
        self.file_repository = file_repository

    def execute(self, media_id):
        """
        Deletes a media item by its ID.

        :param media_id: The ID of the media item to delete.
        :return: True if deletion was successful, False otherwise.
        """
        return self.file_repository.delete(media_id)