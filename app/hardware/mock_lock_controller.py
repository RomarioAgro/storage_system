import logging
import time
from dataclasses import dataclass

from app.hardware.lock_controller import LockController, LockControllerError

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class MockLockCall:
    """Recorded mock lock opening call."""

    controller_address: int
    relay_channel: int
    pulse_seconds: float


class MockLockController(LockController):
    """Development and test lock controller that records cell opening calls."""

    def __init__(self, fail_next_open: bool = False) -> None:
        """Initialize mock controller.

        Args:
            fail_next_open: If true, the next opening attempt raises a controller error.
        """
        self.fail_next_open = fail_next_open
        self.calls: list[MockLockCall] = []

    def open_cell(
        self,
        controller_address: int,
        relay_channel: int,
        pulse_seconds: float = 1.0,
    ) -> None:
        """Record a simulated cell opening.

        Args:
            controller_address: Address of the mock controller.
            relay_channel: Relay channel connected to the cell lock.
            pulse_seconds: Pulse duration in seconds.

        Raises:
            LockControllerError: If parameters are invalid or failure mode is enabled.
        """
        if controller_address <= 0:
            raise LockControllerError("controller_address must be positive")
        if relay_channel <= 0:
            raise LockControllerError("relay_channel must be positive")
        if pulse_seconds <= 0:
            raise LockControllerError("pulse_seconds must be positive")
        if self.fail_next_open:
            self.fail_next_open = False
            raise LockControllerError("Simulated lock controller failure")
        self.calls.append(
            MockLockCall(
                controller_address=controller_address,
                relay_channel=relay_channel,
                pulse_seconds=pulse_seconds,
            )
        )
        logger.info(
            "MOCK open cell: controller_address=%s relay_channel=%s pulse_seconds=%s",
            controller_address,
            relay_channel,
            pulse_seconds,
        )
        time.sleep(min(pulse_seconds, 0.05))
