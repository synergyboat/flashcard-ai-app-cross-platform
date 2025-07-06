# core/entities/user_model.py

from datetime import datetime, timezone
from typing import Optional
from uuid import UUID, uuid4
from pydantic import BaseModel, EmailStr, Field


class UserModel(BaseModel):
    """
    UserModel represents a user
    """
    id: UUID = Field(default_factory=uuid4)
    name: str = Field(default="", max_length=100)
    email: EmailStr
    password_hash: str
    is_active: bool = True
    is_admin: bool = False
    is_premium_user: bool = False
    is_superuser: bool = False
    is_verified: bool = False
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
    last_login: Optional[datetime] = None

    # --- Domain Logic ---

    def can_login(self) -> bool:
        return self.is_active and self.is_verified

    def upgrade_to_premium(self) -> "UserModel":
        return self.model_copy(update={
            "is_premium_user": True,
            "updated_at": datetime.now(timezone.utc)
        })

    def verify_email(self) -> "UserModel":
        return self.model_copy(update={
            "is_verified": True,
            "updated_at": datetime.now(timezone.utc)
        })

    def deactivate(self) -> "UserModel":
        return self.model_copy(update={
            "is_active": False,
            "updated_at": datetime.now(timezone.utc)
        })

    def update_last_login(self) -> "UserModel":
        return self.model_copy(update={
            "last_login": datetime.now(timezone.utc),
            "updated_at": datetime.now(timezone.utc)
        })

    def rename(self, new_name: str) -> "UserModel":
        return self.model_copy(update={
            "name": new_name.strip(),
            "updated_at": datetime.now(timezone.utc)
        })

    def __str__(self):
        return f"User({self.id}, {self.email}, active={self.is_active}, verified={self.is_verified})"

    class Config:
        orm_mode = True
        allow_mutation = False
        frozen = True
        use_enum_values = True
