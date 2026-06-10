from enum import StrEnum


class RoleCode(StrEnum):
    ADMIN = "admin"
    MANAGER = "manager"
    USER = "user"
    SERVICE = "service"


class ControllerType(StrEnum):
    MOCK = "mock"
    USB_RELAY = "usb_relay"
    MODBUS_RTU = "modbus_rtu"


class CellStatus(StrEnum):
    ACTIVE = "active"
    BLOCKED = "blocked"
    MAINTENANCE = "maintenance"


class MovementType(StrEnum):
    FILL = "fill"
    TAKE = "take"
    MOVE_IN = "move_in"
    MOVE_OUT = "move_out"
    ADJUST = "adjust"
    INVENTORY = "inventory"


class AccessEventType(StrEnum):
    LOGIN_SUCCESS = "login_success"
    UNKNOWN_RFID = "unknown_rfid"
    ACCESS_DENIED = "access_denied"
    OPEN_CELL_SUCCESS = "open_cell_success"
    OPEN_CELL_FAILED = "open_cell_failed"
    CLOSE_CONFIRMED = "close_confirmed"
    SESSION_STARTED = "session_started"
    SESSION_COMPLETED = "session_completed"
    SESSION_CANCELLED = "session_cancelled"
    SESSION_TIMEOUT = "session_timeout"
    RELAY_ERROR = "relay_error"
    SYSTEM_STARTUP = "system_startup"


class EventResult(StrEnum):
    OK = "ok"
    DENIED = "denied"
    ERROR = "error"


class SessionOperationType(StrEnum):
    FILL = "fill"
    TAKE = "take"
    OPEN_ONLY = "open_only"
    INVENTORY = "inventory"
    MOVE_FROM = "move_from"
    MOVE_TO = "move_to"


class SessionStatus(StrEnum):
    CREATED = "created"
    OPENING = "opening"
    OPENED = "opened"
    WAITING_CLOSE = "waiting_close"
    CLOSE_CONFIRMED = "close_confirmed"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    ERROR = "error"


ACTIVE_SESSION_STATUSES = {
    SessionStatus.CREATED,
    SessionStatus.OPENING,
    SessionStatus.OPENED,
    SessionStatus.WAITING_CLOSE,
    SessionStatus.CLOSE_CONFIRMED,
}
