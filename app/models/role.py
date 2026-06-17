from sqlalchemy import Boolean, JSON, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, created_at_col, updated_at_col


class Role(Base):
    __tablename__ = "roles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    code: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(100), unique=True)
    permissions: Mapped[list[str] | None] = mapped_column(JSON, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[created_at_col]
    updated_at: Mapped[updated_at_col]

    users = relationship("User", back_populates="role")
