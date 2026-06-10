from datetime import datetime
from typing import Annotated

from sqlalchemy.orm import DeclarativeBase, mapped_column

from app.core.time import UTCDateTime, utc_now

created_at_col = Annotated[datetime, mapped_column(UTCDateTime(), default=utc_now)]
updated_at_col = Annotated[
    datetime,
    mapped_column(UTCDateTime(), default=utc_now, onupdate=utc_now),
]


class Base(DeclarativeBase):
    """Base class for all SQLAlchemy ORM models."""

    pass
