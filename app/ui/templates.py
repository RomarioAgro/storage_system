from pathlib import Path

from fastapi.templating import Jinja2Templates

from app.core.config import settings
from app.core.time import format_local_datetime


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


templates = Jinja2Templates(directory=template_directory())
templates.env.filters["local_datetime"] = lambda value: format_local_datetime(
    value,
    settings.local_timezone,
)
