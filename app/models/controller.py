from sqlalchemy import Boolean, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.enums import ControllerType
from app.models.base import Base, created_at_col
from app.models.types import enum_column


class Controller(Base):
    __tablename__ = "controllers"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(200), unique=True)
    controller_type: Mapped[ControllerType] = mapped_column(enum_column(ControllerType), index=True)
    address: Mapped[int | None] = mapped_column(Integer, nullable=True)
    port: Mapped[str | None] = mapped_column(String(100), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    comment: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[created_at_col]

    cells = relationship("Cell", back_populates="controller")
