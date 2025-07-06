from domain.interfaces.user_repository_interface import IUserRepository

class GetUserUseCase:
    """
    GetUserUseCase is responsible for retrieving user information
    """
    def __init__(self, user_repository: IUserRepository):
        self.user_repository = user_repository

    def by_id(self, user_id):
        """
        Retrieve a user by their ID.
        :param user_id:
        :return: UserModel - the user with the given ID
        :raises ValueError: If user is not found
        """
        user = self.user_repository.get_user_by_id(user_id)
        if not user:
            raise ValueError("User not found")
        return user

    def by_email(self, email):
        """
        Retrieve a user by their email address.
        :param email:
        :return: UserModel - the user with the given email
        :raises ValueError: If user is not found
        """
        user = self.user_repository.get_user_by_email(email)
        if not user:
            raise ValueError("User not found")
        return user
