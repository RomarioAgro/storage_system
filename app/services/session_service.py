from datetime import datetime

from sqlalchemy.exc import IntegrityError
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.core.enums import (
    ACTIVE_SESSION_STATUSES,
    AccessEventType,
    EventResult,
    SessionOperationType,
    SessionStatus,
)
from app.models.cell import Cell
from app.models.cell_session import CellSession
from app.models.user import User
from app.services.access_log_service import AccessLogService
from app.services.errors import ActiveSessionExistsError, InvalidSessionStateError, NotFoundError


class SessionService:
    @staticmethod
    def get_active_session(db: Session) -> CellSession | None:
        return db.scalars(
            select(CellSession)
            .options(
                joinedload(CellSession.cell),
                joinedload(CellSession.user),
                joinedload(CellSession.product),
            )
            .where(CellSession.status.in_(ACTIVE_SESSION_STATUSES))
            .order_by(CellSession.created_at.asc())
        ).first()

    @staticmethod
    def ensure_no_active_session(db: Session) -> None:
        active = SessionService.get_active_session(db)
        if active:
            raise ActiveSessionExistsError(
                f"Active session already exists: session_id={active.id} cell_id={active.cell_id}"
            )

    @staticmethod
    def create_session(
        db: Session,
        user: User,
        cell: Cell,
        operation_type: SessionOperationType,
        product_id: int | None = None,
        planned_quantity=None,
        comment: str | None = None,
    ) -> CellSession:
        SessionService.ensure_no_active_session(db)
        session = CellSession(
            user_id=user.id,
            cell_id=cell.id,
            operation_type=operation_type,
            status=SessionStatus.CREATED,
            product_id=product_id,
            planned_quantity=planned_quantity,
            comment=comment,
        )
        db.add(session)
        try:
            db.flush()
        except IntegrityError as exc:
            db.rollback()
            raise ActiveSessionExistsError("Active session already exists") from exc
        AccessLogService.log(
            db,
            event_type=AccessEventType.SESSION_STARTED,
            result=EventResult.OK,
            user_id=user.id,
            cell_id=cell.id,
            session_id=session.id,
        )
        return session

    @staticmethod
    def mark_opening(db: Session, session: CellSession) -> None:
        session.status = SessionStatus.OPENING
        db.flush()

    @staticmethod
    def mark_opened(db: Session, session: CellSession) -> None:
        session.status = SessionStatus.WAITING_CLOSE
        session.opened_at = datetime.utcnow()
        db.flush()

    @staticmethod
    def get_session(db: Session, session_id: int) -> CellSession:
        session = db.get(CellSession, session_id)
        if session is None:
            raise NotFoundError("Session not found")
        return session

    @staticmethod
    def confirm_close(db: Session, session_id: int) -> CellSession:
        session = SessionService.get_session(db, session_id)
        if session.status != SessionStatus.WAITING_CLOSE:
            raise InvalidSessionStateError(
                f"Cannot confirm close while session status is {session.status}"
            )
        session.status = SessionStatus.CLOSE_CONFIRMED
        session.close_confirmed_at = datetime.utcnow()
        AccessLogService.log(
            db,
            event_type=AccessEventType.CLOSE_CONFIRMED,
            result=EventResult.OK,
            user_id=session.user_id,
            cell_id=session.cell_id,
            session_id=session.id,
        )
        db.commit()
        db.refresh(session)
        return session

    @staticmethod
    def complete(db: Session, session: CellSession) -> CellSession:
        session.status = SessionStatus.COMPLETED
        session.completed_at = datetime.utcnow()
        AccessLogService.log(
            db,
            event_type=AccessEventType.SESSION_COMPLETED,
            result=EventResult.OK,
            user_id=session.user_id,
            cell_id=session.cell_id,
            session_id=session.id,
        )
        db.flush()
        return session

    @staticmethod
    def cancel(db: Session, session_id: int, reason: str | None = None) -> CellSession:
        session = SessionService.get_session(db, session_id)
        if session.status not in ACTIVE_SESSION_STATUSES:
            raise InvalidSessionStateError(f"Session is not active: {session.status}")
        session.status = SessionStatus.CANCELLED
        session.cancelled_at = datetime.utcnow()
        session.cancel_reason = reason
        AccessLogService.log(
            db,
            event_type=AccessEventType.SESSION_CANCELLED,
            result=EventResult.OK,
            user_id=session.user_id,
            cell_id=session.cell_id,
            session_id=session.id,
            details=reason,
        )
        db.commit()
        db.refresh(session)
        return session
