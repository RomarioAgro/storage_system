from datetime import UTC, datetime
from zoneinfo import ZoneInfo

from sqlalchemy import DateTime
from sqlalchemy.engine.interfaces import Dialect
from sqlalchemy.types import TypeDecorator


def utc_now() -> datetime:
    """Return the current time as a timezone-aware UTC datetime.

    Returns:
        Current wall-clock time with `UTC` timezone information attached.
    """
    return datetime.now(UTC)


def format_local_datetime(value: datetime | None, timezone_name: str) -> str:
    """Format a timestamp in the configured local timezone.

    Args:
        value: Datetime to display. Naive values are treated as UTC.
        timezone_name: IANA timezone name, for example `Europe/Moscow`.

    Returns:
        Human-readable datetime with numeric UTC offset, or an empty string for
        missing values.

    Raises:
        ZoneInfoNotFoundError: If `timezone_name` is not a valid IANA timezone.
    """
    if value is None:
        return ""
    if value.tzinfo is None:
        value = value.replace(tzinfo=UTC)
    local_value = value.astimezone(ZoneInfo(timezone_name))
    return local_value.strftime("%Y-%m-%d %H:%M:%S %z")[:-2] + ":" + local_value.strftime("%z")[-2:]


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
