from functools import lru_cache

from sqlalchemy.orm import Session

from app.core.config import settings
from app.hardware.lock_controller import LockController
from app.hardware.mock_lock_controller import MockLockController
from app.hardware.modbus_relay_controller import ModbusRelayController
from app.hardware.usb_relay_controller import UsbRelayController


@lru_cache
def get_lock_controller() -> LockController:
    if settings.lock_controller == "mock":
        return MockLockController()
    if settings.lock_controller == "usb_relay":
        return UsbRelayController()
    if settings.lock_controller == "modbus_rtu":
        return ModbusRelayController()
    raise RuntimeError(f"Unknown lock controller type: {settings.lock_controller}")


DbSession = Session
