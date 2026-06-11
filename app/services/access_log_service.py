from sqlalchemy.orm import Session

from app.core.enums import AccessEventType, EventResult
from app.models.access_event import AccessEvent


class AccessLogService:
    @staticmethod
    def log(
        db: Session,
        event_type: AccessEventType,
        result: EventResult,
        user_id: int | None = None,
        rfid_uid: str | None = None,
        client_ip: str | None = None,
        cell_id: int | None = None,
        session_id: int | None = None,
        details: str | None = None,
    ) -> AccessEvent:
        event = AccessEvent(
            event_type=event_type,
            result=result,
            user_id=user_id,
            rfid_uid=rfid_uid,
            client_ip=client_ip,
            cell_id=cell_id,
            session_id=session_id,
            details=details,
        )
        db.add(event)
        db.flush()
        return event
