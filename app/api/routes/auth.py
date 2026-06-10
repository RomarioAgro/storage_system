from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.auth import RfidAuthRequest, RfidAuthResponse
from app.services.auth_service import AuthService

router = APIRouter()


@router.post("/rfid", response_model=RfidAuthResponse)
def authenticate_rfid(payload: RfidAuthRequest, db: Session = Depends(get_db)) -> RfidAuthResponse:
    user = AuthService.authenticate_rfid(db, payload.rfid_uid)
    return RfidAuthResponse(user_id=user.id, name=user.name, role=user.role.code.value)
