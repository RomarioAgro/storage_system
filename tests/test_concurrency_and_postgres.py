from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import pytest
from sqlalchemy import create_engine, inspect
from sqlalchemy.orm import sessionmaker

from app.core.enums import CellStatus, ControllerType, RoleCode
from app.hardware.mock_lock_controller import MockLockController
from app.models import Cell, Controller, Role, User
from app.models.base import Base
from app.services.errors import ActiveSessionExistsError
from app.services.operation_service import OperationService


def _seed_concurrency_db(SessionTesting):
    db = SessionTesting()
    try:
        role = Role(code=RoleCode.SERVICE, name="Service")
        db.add(role)
        db.flush()
        user = User(name="Service", rfid_uid="service-card", role_id=role.id)
        controller = Controller(name="Mock", controller_type=ControllerType.MOCK, address=1)
        db.add_all([user, controller])
        db.flush()
        db.add_all(
            [
                Cell(
                    number=1,
                    status=CellStatus.ACTIVE,
                    controller_id=controller.id,
                    controller_address=1,
                    relay_channel=1,
                ),
                Cell(
                    number=2,
                    status=CellStatus.ACTIVE,
                    controller_id=controller.id,
                    controller_address=1,
                    relay_channel=2,
                ),
            ]
        )
        db.commit()
        return user.id
    finally:
        db.close()


def test_concurrent_open_only_creates_only_one_active_session(tmp_path: Path):
    engine = create_engine(
        f"sqlite:///{tmp_path / 'concurrency.db'}",
        connect_args={"check_same_thread": False},
        future=True,
    )
    Base.metadata.create_all(engine)
    SessionTesting = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)
    user_id = _seed_concurrency_db(SessionTesting)
    lock_controller = MockLockController()

    def start(cell_id: int) -> str:
        db = SessionTesting()
        try:
            OperationService.start_open_only(db, lock_controller, user_id=user_id, cell_id=cell_id)
            return "opened"
        except ActiveSessionExistsError:
            return "blocked"
        finally:
            db.close()

    with ThreadPoolExecutor(max_workers=2) as executor:
        results = list(executor.map(start, [1, 2]))

    assert results.count("opened") == 1
    assert results.count("blocked") == 1
    assert len(lock_controller.calls) == 1


def test_postgresql_partial_active_session_index_exists_when_configured(monkeypatch):
    url = __import__("os").environ.get("POSTGRES_TEST_DATABASE_URL")
    if not url:
        pytest.skip("Set POSTGRES_TEST_DATABASE_URL to run PostgreSQL integration check")

    engine = create_engine(url, future=True)
    try:
        indexes = inspect(engine).get_indexes("cell_sessions")
    finally:
        engine.dispose()

    assert any(index["name"] == "only_one_active_cell_session" for index in indexes)
