from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session

from app.core.client_ip import client_ip_from_request
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
def confirm_close(request: Request, session_id: int, db: Session = Depends(get_db)):
    return SessionService.confirm_close(
        db,
        session_id=session_id,
        client_ip=client_ip_from_request(request),
    )


@router.post("/{session_id}/cancel", response_model=SessionResponse)
def cancel_session(
    request: Request,
    session_id: int,
    payload: CancelSessionRequest,
    db: Session = Depends(get_db),
):
    return SessionService.cancel(
        db,
        session_id=session_id,
        reason=payload.reason,
        client_ip=client_ip_from_request(request),
    )
