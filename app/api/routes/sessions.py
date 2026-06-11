from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.session import ActiveSessionResponse, CancelSessionRequest, SessionResponse
from app.services.session_service import SessionService

router = APIRouter()


@router.get("/active", response_model=ActiveSessionResponse)
def get_active_session(db: Session = Depends(get_db)) -> ActiveSessionResponse:
    session = SessionService.get_active_session(db)
    if session is None:
        return ActiveSessionResponse(has_active_session=False)
    return ActiveSessionResponse(
        has_active_session=True,
        session=session,
        cell_number=session.cell.number if session.cell else None,
        user_name=session.user.full_name if session.user else None,
        product_name=session.product.name if session.product else None,
    )


@router.post("/{session_id}/confirm-close", response_model=SessionResponse)
def confirm_close(session_id: int, db: Session = Depends(get_db)):
    return SessionService.confirm_close(db, session_id=session_id)


@router.post("/{session_id}/cancel", response_model=SessionResponse)
def cancel_session(session_id: int, payload: CancelSessionRequest, db: Session = Depends(get_db)):
    return SessionService.cancel(db, session_id=session_id, reason=payload.reason)
