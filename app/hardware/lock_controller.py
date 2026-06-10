from abc import ABC, abstractmethod


class LockControllerError(RuntimeError):
    """Raised when a lock controller cannot open a cell."""

    pass


class LockController(ABC):
    """Abstract lock controller used by business services to open cells."""

    @abstractmethod
    def open_cell(
        self,
        controller_address: int,
        relay_channel: int,
        pulse_seconds: float = 1.0,
    ) -> None:
        """Open one cell lock using a short relay pulse.

        Args:
            controller_address: Address of the relay controller.
            relay_channel: Relay channel connected to the cell lock.
            pulse_seconds: Pulse duration in seconds.

        Raises:
            LockControllerError: If the lock cannot be opened.
        """
