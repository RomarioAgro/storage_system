from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session

from app.core.client_ip import client_ip_from_request
from app.core.database import get_db
from app.schemas.auth import RfidAuthRequest, RfidAuthResponse
from app.services.auth_service import AuthService

router = APIRouter()


@router.post("/rfid", response_model=RfidAuthResponse)
def authenticate_rfid(
    request: Request,
    payload: RfidAuthRequest,
    db: Session = Depends(get_db),
) -> RfidAuthResponse:
    user = AuthService.authenticate_rfid(
        db,
        payload.rfid_uid,
        client_ip=client_ip_from_request(request),
    )
    return RfidAuthResponse(user_id=user.id, name=user.full_name, role=str(user.role.code))
