from app.hardware.lock_controller import LockController, LockControllerError


class UsbRelayController(LockController):
    """Protocol stub for a future USB relay implementation."""

    def __init__(self, port: str | None = None) -> None:
        """Initialize USB relay stub.

        Args:
            port: Optional serial or device path reserved for future use.
        """
        self.port = port

    def open_cell(
        self,
        controller_address: int,
        relay_channel: int,
        pulse_seconds: float = 1.0,
    ) -> None:
        """Reject opening because real USB relay protocol is outside MVP.

        Args:
            controller_address: Relay controller address.
            relay_channel: Relay channel.
            pulse_seconds: Pulse duration in seconds.

        Raises:
            LockControllerError: Always, until a real protocol is implemented.
        """
        raise LockControllerError(
            "UsbRelayController is a protocol stub. Implement selected relay board commands here."
        )
