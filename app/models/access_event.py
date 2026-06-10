from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.enums import AccessEventType, EventResult
from app.models.base import Base
from app.models.types import enum_column


class AccessEvent(Base):
    __tablename__ = "access_events"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=False), default=datetime.utcnow, index=True)
    user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True, index=True)
    rfid_uid: Mapped[str | None] = mapped_column(String(128), nullable=True, index=True)
    cell_id: Mapped[int | None] = mapped_column(ForeignKey("cells.id"), nullable=True, index=True)
    session_id: Mapped[int | None] = mapped_column(ForeignKey("cell_sessions.id"), nullable=True, index=True)
    event_type: Mapped[AccessEventType] = mapped_column(enum_column(AccessEventType), index=True)
    result: Mapped[EventResult] = mapped_column(enum_column(EventResult), index=True)
    details: Mapped[str | None] = mapped_column(Text, nullable=True)
