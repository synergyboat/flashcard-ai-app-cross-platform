# core/interfaces/user_repository.py

from abc import ABC, abstractmethod
from typing import Optional
from uuid import UUID
from domain.entities import UserModel

class IUserRepository(ABC):
    @abstractmethod
    def get_user_by_id(self, user_id: UUID) -> Optional[UserModel]:
        """Retrieve a user by their ID."""
        pass

    @abstractmethod
    def get_user_by_email(self, email: str) -> Optional[UserModel]:
        """Retrieve a user by their email address."""
        pass

    @abstractmethod
    def create_user(self, user: UserModel) -> UserModel:
        """Create a new user."""
        pass

    @abstractmethod
    def update_user(self, user: UserModel) -> UserModel:
        """Update an existing user's information."""
        pass

    @abstractmethod
    def delete_user(self, user_id: UUID) -> None:
        """Delete a user by their ID."""
        pass
