from sqlalchemy import Boolean, ForeignKey, Integer, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.enums import CellStatus
from app.models.base import Base, created_at_col, updated_at_col
from app.models.types import enum_column


class Cell(Base):
    __tablename__ = "cells"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    number: Mapped[int] = mapped_column(Integer, unique=True, index=True)
    status: Mapped[CellStatus] = mapped_column(enum_column(CellStatus), default=CellStatus.ACTIVE)
    controller_id: Mapped[int | None] = mapped_column(ForeignKey("controllers.id"), nullable=True)
    controller_address: Mapped[int | None] = mapped_column(Integer, nullable=True)
    relay_channel: Mapped[int | None] = mapped_column(Integer, nullable=True)
    has_close_sensor: Mapped[bool] = mapped_column(Boolean, default=False)
    close_sensor_controller_address: Mapped[int | None] = mapped_column(Integer, nullable=True)
    close_sensor_channel: Mapped[int | None] = mapped_column(Integer, nullable=True)
    comment: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[created_at_col]
    updated_at: Mapped[updated_at_col]

    controller = relationship("Controller", back_populates="cells")
    stock_items = relationship("StockItem", back_populates="cell")
    sessions = relationship("CellSession", back_populates="cell")
