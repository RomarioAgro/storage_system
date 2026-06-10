from app.hardware.lock_controller import LockController, LockControllerError


class ModbusRelayController(LockController):
    """Protocol stub for a future Modbus RTU relay implementation."""

    def __init__(self, port: str | None = None, baudrate: int = 9600) -> None:
        """Initialize Modbus relay stub.

        Args:
            port: Optional serial port reserved for future use.
            baudrate: Serial baud rate reserved for future use.
        """
        self.port = port
        self.baudrate = baudrate

    def open_cell(
        self,
        controller_address: int,
        relay_channel: int,
        pulse_seconds: float = 1.0,
    ) -> None:
        """Reject opening because real Modbus RTU protocol is outside MVP.

        Args:
            controller_address: Modbus slave address.
            relay_channel: Relay channel.
            pulse_seconds: Pulse duration in seconds.

        Raises:
            LockControllerError: Always, until a real protocol is implemented.
        """
        raise LockControllerError(
            "ModbusRelayController is a protocol stub. Implement Modbus RTU relay commands here."
        )
