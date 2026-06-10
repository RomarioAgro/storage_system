from datetime import datetime
from decimal import Decimal

from sqlalchemy import DateTime, ForeignKey, Index, Integer, Numeric, Text, literal_column
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.enums import ACTIVE_SESSION_STATUSES, SessionOperationType, SessionStatus
from app.models.base import Base, created_at_col, updated_at_col
from app.models.types import enum_column


class CellSession(Base):
    __tablename__ = "cell_sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    cell_id: Mapped[int] = mapped_column(ForeignKey("cells.id"), index=True)
    operation_type: Mapped[SessionOperationType] = mapped_column(
        enum_column(SessionOperationType), index=True
    )
    status: Mapped[SessionStatus] = mapped_column(
        enum_column(SessionStatus), default=SessionStatus.CREATED, index=True
    )
    product_id: Mapped[int | None] = mapped_column(ForeignKey("products.id"), nullable=True, index=True)
    planned_quantity: Mapped[Decimal | None] = mapped_column(Numeric(12, 3), nullable=True)
    opened_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=False), nullable=True)
    close_confirmed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=False), nullable=True)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=False), nullable=True)
    cancelled_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=False), nullable=True)
    cancel_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    comment: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[created_at_col]
    updated_at: Mapped[updated_at_col]

    user = relationship("User", back_populates="sessions")
    cell = relationship("Cell", back_populates="sessions")
    product = relationship("Product")
    stock_movements = relationship("StockMovement", back_populates="session")

    __table_args__ = (
        Index(
            "only_one_active_cell_session",
            literal_column("true"),
            unique=True,
            postgresql_where=status.in_([item.value for item in ACTIVE_SESSION_STATUSES]),
            sqlite_where=status.in_([item.value for item in ACTIVE_SESSION_STATUSES]),
        ),
    )
