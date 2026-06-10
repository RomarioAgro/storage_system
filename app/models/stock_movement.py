from datetime import datetime
from decimal import Decimal

from sqlalchemy import DateTime, ForeignKey, Integer, Numeric, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.enums import MovementType
from app.models.base import Base
from app.models.types import enum_column


class StockMovement(Base):
    __tablename__ = "stock_movements"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=False), default=datetime.utcnow, index=True)
    user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True, index=True)
    product_id: Mapped[int] = mapped_column(ForeignKey("products.id"), index=True)
    cell_id: Mapped[int] = mapped_column(ForeignKey("cells.id"), index=True)
    session_id: Mapped[int | None] = mapped_column(ForeignKey("cell_sessions.id"), nullable=True, index=True)
    movement_type: Mapped[MovementType] = mapped_column(enum_column(MovementType), index=True)
    quantity: Mapped[Decimal] = mapped_column(Numeric(12, 3))
    quantity_before: Mapped[Decimal] = mapped_column(Numeric(12, 3))
    quantity_after: Mapped[Decimal] = mapped_column(Numeric(12, 3))
    comment: Mapped[str | None] = mapped_column(Text, nullable=True)

    product = relationship("Product", back_populates="movements")
    session = relationship("CellSession", back_populates="stock_movements")
