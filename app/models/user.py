from sqlalchemy import Boolean, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, created_at_col, updated_at_col


class User(Base):
    """Application user authenticated by RFID and authorized by role."""

    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    last_name: Mapped[str] = mapped_column(String(100), index=True)
    first_name: Mapped[str] = mapped_column(String(100), index=True)
    middle_name: Mapped[str | None] = mapped_column(String(100), nullable=True)
    department: Mapped[str | None] = mapped_column(String(200), nullable=True, index=True)
    rfid_uid: Mapped[str] = mapped_column(String(128), unique=True, index=True)
    role_id: Mapped[int] = mapped_column(ForeignKey("roles.id"), index=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[created_at_col]
    updated_at: Mapped[updated_at_col]

    role = relationship("Role", back_populates="users")
    sessions = relationship("CellSession", back_populates="user")

    @property
    def full_name(self) -> str:
        """Return user surname, name, and patronymic as display text.

        Returns:
            Space-separated full name without empty parts.
        """
        return " ".join(part for part in (self.last_name, self.first_name, self.middle_name) if part)

    @property
    def name(self) -> str:
        """Return backward-compatible display name.

        Returns:
            The same value as full_name for older UI/API code paths.
        """
        return self.full_name
