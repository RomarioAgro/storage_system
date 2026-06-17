from pathlib import Path

from fastapi.templating import Jinja2Templates

from app.core.config import settings
from app.core.time import format_local_datetime

SESSION_STATUS_LABELS = {
    "created": "создана",
    "opening": "открывается",
    "opened": "открыта",
    "waiting_close": "ожидает закрытия",
    "close_confirmed": "закрытие подтверждено",
    "completed": "завершена",
    "cancelled": "отменена",
    "error": "ошибка",
}
OPERATION_TYPE_LABELS = {
    "fill": "пополнение",
    "take": "выдача",
    "inventory": "инвентаризация",
    "open_only": "открытие без изменения остатка",
}


def template_directory() -> str:
    """Return the absolute path to application templates.

    Returns:
        Path string used by Starlette's Jinja2 template loader.
    """
    return str(Path(__file__).resolve().parents[1] / "templates")


def static_directory() -> str:
    """Return the absolute path to static UI assets.

    Returns:
        Path string used by FastAPI static file mounting.
    """
    return str(Path(__file__).resolve().parents[1] / "static")


def enum_label(value: object, labels: dict[str, str]) -> str:
    """Return a user-facing label for enum-like values.

    Args:
        value: Enum, string, or another printable value.
        labels: Mapping from stored enum value to UI label.

    Returns:
        Localized label when known, otherwise the original value as text.
    """
    key = getattr(value, "value", value)
    return labels.get(str(key), str(key))


templates = Jinja2Templates(directory=template_directory())
templates.env.filters["local_datetime"] = lambda value: format_local_datetime(
    value,
    settings.local_timezone,
)
templates.env.filters["session_status"] = lambda value: enum_label(value, SESSION_STATUS_LABELS)
templates.env.filters["operation_type"] = lambda value: enum_label(value, OPERATION_TYPE_LABELS)
