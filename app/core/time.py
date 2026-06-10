from datetime import UTC, datetime

from sqlalchemy import DateTime
from sqlalchemy.engine.interfaces import Dialect
from sqlalchemy.types import TypeDecorator


def utc_now() -> datetime:
    """Return the current time as a timezone-aware UTC datetime.

    Returns:
        Current wall-clock time with `UTC` timezone information attached.
    """
    return datetime.now(UTC)


class UTCDateTime(TypeDecorator):
    """Store and load timestamps as timezone-aware UTC values.

    SQLite may return naive `datetime` values even for timezone-enabled columns.
    This type normalizes values on both write and read so ORM code can rely on
    aware UTC datetimes across SQLite development and PostgreSQL deployments.
    """

    impl = DateTime(timezone=True)
    cache_ok = True

    def process_bind_param(self, value: datetime | None, dialect: Dialect) -> datetime | None:
        """Normalize values before binding them to SQL statements.

        Args:
            value: Datetime supplied by application code or SQLAlchemy defaults.
            dialect: SQLAlchemy database dialect.

        Returns:
            Datetime converted to UTC, or `None`.
        """
        if value is None:
            return None
        if value.tzinfo is None:
            return value.replace(tzinfo=UTC)
        return value.astimezone(UTC)

    def process_result_value(self, value: datetime | None, dialect: Dialect) -> datetime | None:
        """Normalize values loaded from the database.

        Args:
            value: Datetime returned by the database driver.
            dialect: SQLAlchemy database dialect.

        Returns:
            Timezone-aware UTC datetime, or `None`.
        """
        if value is None:
            return None
        if value.tzinfo is None:
            return value.replace(tzinfo=UTC)
        return value.astimezone(UTC)
