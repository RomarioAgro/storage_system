from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel

from app.schemas.common import OrmModel


class SessionResponse(OrmModel):
    id: int
    user_id: int
    cell_id: int
    operation_type: str
    status: str
    product_id: int | None
    planned_quantity: Decimal | None
    opened_at: datetime | None
    close_confirmed_at: datetime | None
    completed_at: datetime | None
    cancelled_at: datetime | None
    cancel_reason: str | None
    comment: str | None
    created_at: datetime
    updated_at: datetime


class CancelSessionRequest(BaseModel):
    reason: str | None = None


class ActiveSessionResponse(BaseModel):
    has_active_session: bool
    session: SessionResponse | None = None
    cell_number: int | None = None
    user_name: str | None = None
    product_name: str | None = None
