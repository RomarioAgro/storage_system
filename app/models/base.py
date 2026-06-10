from datetime import datetime
from typing import Annotated

from sqlalchemy import DateTime
from sqlalchemy.orm import DeclarativeBase, mapped_column

created_at_col = Annotated[datetime, mapped_column(DateTime(timezone=False), default=datetime.utcnow)]
updated_at_col = Annotated[
    datetime,
    mapped_column(DateTime(timezone=False), default=datetime.utcnow, onupdate=datetime.utcnow),
]


class Base(DeclarativeBase):
    pass
