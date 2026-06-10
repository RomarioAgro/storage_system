from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.core.enums import AccessEventType, EventResult
from app.models.user import User
from app.services.access_log_service import AccessLogService
from app.services.errors import PermissionDeniedError


class AuthService:
    @staticmethod
    def authenticate_rfid(db: Session, rfid_uid: str) -> User:
        user = db.scalars(
            select(User).options(joinedload(User.role)).where(User.rfid_uid == rfid_uid)
        ).first()
        if user is None:
            AccessLogService.log(
                db,
                event_type=AccessEventType.UNKNOWN_RFID,
                result=EventResult.DENIED,
                rfid_uid=rfid_uid,
                details="RFID card is not registered",
            )
            db.commit()
            raise PermissionDeniedError("RFID card is not registered")
        if not user.is_active or not user.role.is_active:
            AccessLogService.log(
                db,
                event_type=AccessEventType.ACCESS_DENIED,
                result=EventResult.DENIED,
                user_id=user.id,
                rfid_uid=rfid_uid,
                details="User or role is inactive",
            )
            db.commit()
            raise PermissionDeniedError("User is inactive")
        AccessLogService.log(
            db,
            event_type=AccessEventType.LOGIN_SUCCESS,
            result=EventResult.OK,
            user_id=user.id,
            rfid_uid=rfid_uid,
        )
        db.commit()
        db.refresh(user)
        return user
