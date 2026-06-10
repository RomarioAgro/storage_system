from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.staticfiles import StaticFiles
from starlette.middleware.sessions import SessionMiddleware

from app.api.error_handlers import register_error_handlers
from app.api.router import api_router
from app.core.config import settings
from app.core.database import engine, SessionLocal
from app.core.enums import AccessEventType, EventResult
from app.models.base import Base
from app.services.access_log_service import AccessLogService
from app.services.session_service import SessionService
from app.ui.admin import router as admin_router
from app.ui.terminal import router as terminal_router
from app.ui.templates import static_directory

# Import models so SQLAlchemy metadata is populated when create_all is used.
import app.models  # noqa: F401


def create_app() -> FastAPI:
    app = FastAPI(title=settings.app_name)
    app.add_middleware(
        SessionMiddleware,
        secret_key=settings.ui_session_secret,
        same_site="lax",
        https_only=False,
    )
    register_error_handlers(app)
    app.mount("/static", StaticFiles(directory=static_directory()), name="static")
    app.include_router(api_router, prefix="/api")
    app.include_router(terminal_router)
    app.include_router(admin_router)

    @app.get("/", include_in_schema=False)
    def index() -> RedirectResponse:
        """Redirect browser users to the terminal UI."""
        return RedirectResponse(url="/terminal")

    @app.on_event("startup")
    def on_startup() -> None:
        if settings.auto_create_tables:
            Base.metadata.create_all(bind=engine)
        db = SessionLocal()
        try:
            AccessLogService.log(
                db,
                event_type=AccessEventType.SYSTEM_STARTUP,
                result=EventResult.OK,
                details="Application startup",
            )
            active_session = SessionService.get_active_session(db)
            if active_session is not None:
                AccessLogService.log(
                    db,
                    event_type=AccessEventType.SYSTEM_STARTUP,
                    result=EventResult.OK,
                    session_id=active_session.id,
                    cell_id=active_session.cell_id,
                    details="Application startup with unfinished active cell session",
                )
            db.commit()
        finally:
            db.close()

    return app


app = create_app()
