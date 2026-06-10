from decimal import Decimal

import pytest

from app.core.enums import AccessEventType, MovementType, SessionStatus
from app.hardware.mock_lock_controller import MockLockController
from app.models.access_event import AccessEvent
from app.models.stock_item import StockItem
from app.models.stock_movement import StockMovement
from app.services.errors import ActiveSessionExistsError, InsufficientStockError
from app.services.operation_service import OperationService
from app.services.session_service import SessionService


def _stock_quantity(db, product_id: int, cell_id: int) -> Decimal:
    return db.query(StockItem).filter_by(product_id=product_id, cell_id=cell_id).one().quantity


def test_fill_changes_stock_only_after_close_and_confirm(db, mock_lock_controller, sample_data):
    data = sample_data()

    session = OperationService.start_fill(
        db,
        mock_lock_controller,
        user_id=data["users"]["user"].id,
        product_id=data["product"].id,
        cell_id=data["cell1"].id,
        quantity=Decimal("2.000"),
    )

    assert session.status == SessionStatus.WAITING_CLOSE
    assert _stock_quantity(db, data["product"].id, data["cell1"].id) == Decimal("5.000")
    assert len(mock_lock_controller.calls) == 1

    SessionService.confirm_close(db, session.id)
    assert _stock_quantity(db, data["product"].id, data["cell1"].id) == Decimal("5.000")

    OperationService.confirm_fill(db, session.id)
    assert _stock_quantity(db, data["product"].id, data["cell1"].id) == Decimal("7.000")
    movement = db.query(StockMovement).one()
    assert movement.movement_type == MovementType.FILL
    assert movement.quantity_before == Decimal("5.000")
    assert movement.quantity_after == Decimal("7.000")


def test_take_changes_stock_only_after_close_and_confirm(db, mock_lock_controller, sample_data):
    data = sample_data()

    session = OperationService.start_take(
        db,
        mock_lock_controller,
        user_id=data["users"]["user"].id,
        product_id=data["product"].id,
        cell_id=data["cell1"].id,
        quantity=Decimal("2.000"),
    )

    assert _stock_quantity(db, data["product"].id, data["cell1"].id) == Decimal("5.000")
    SessionService.confirm_close(db, session.id)
    assert _stock_quantity(db, data["product"].id, data["cell1"].id) == Decimal("5.000")

    OperationService.confirm_take(db, session.id)
    assert _stock_quantity(db, data["product"].id, data["cell1"].id) == Decimal("3.000")
    movement = db.query(StockMovement).one()
    assert movement.movement_type == MovementType.TAKE
    assert movement.quantity_before == Decimal("5.000")
    assert movement.quantity_after == Decimal("3.000")


def test_take_more_than_available_does_not_open_lock(db, mock_lock_controller, sample_data):
    data = sample_data()

    with pytest.raises(InsufficientStockError):
        OperationService.start_take(
            db,
            mock_lock_controller,
            user_id=data["users"]["user"].id,
            product_id=data["product"].id,
            cell_id=data["cell1"].id,
            quantity=Decimal("99.000"),
        )

    assert mock_lock_controller.calls == []
    assert _stock_quantity(db, data["product"].id, data["cell1"].id) == Decimal("5.000")


def test_cancel_does_not_change_stock(db, mock_lock_controller, sample_data):
    data = sample_data()
    session = OperationService.start_fill(
        db,
        mock_lock_controller,
        user_id=data["users"]["user"].id,
        product_id=data["product"].id,
        cell_id=data["cell1"].id,
        quantity=Decimal("2.000"),
    )

    SessionService.cancel(db, session.id, reason="test")

    assert _stock_quantity(db, data["product"].id, data["cell1"].id) == Decimal("5.000")
    assert db.query(StockMovement).count() == 0
    event = db.query(AccessEvent).order_by(AccessEvent.id.desc()).first()
    assert event.event_type == AccessEventType.SESSION_CANCELLED


def test_second_active_session_is_blocked_before_lock_opens(db, mock_lock_controller, sample_data):
    data = sample_data()
    OperationService.start_open_only(
        db,
        mock_lock_controller,
        user_id=data["users"]["service"].id,
        cell_id=data["cell1"].id,
    )

    with pytest.raises(ActiveSessionExistsError):
        OperationService.start_open_only(
            db,
            mock_lock_controller,
            user_id=data["users"]["service"].id,
            cell_id=data["cell2"].id,
        )

    assert len(mock_lock_controller.calls) == 1


def test_active_session_is_found_after_new_db_session(engine, db, mock_lock_controller, sample_data):
    data = sample_data()
    session = OperationService.start_open_only(
        db,
        mock_lock_controller,
        user_id=data["users"]["service"].id,
        cell_id=data["cell1"].id,
    )
    db.close()

    from sqlalchemy.orm import sessionmaker

    SessionTesting = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)
    new_db = SessionTesting()
    try:
        active = SessionService.get_active_session(new_db)
        assert active.id == session.id
    finally:
        new_db.close()


def test_open_only_does_not_change_stock(db, mock_lock_controller, sample_data):
    data = sample_data()
    session = OperationService.start_open_only(
        db,
        mock_lock_controller,
        user_id=data["users"]["service"].id,
        cell_id=data["cell1"].id,
    )

    SessionService.confirm_close(db, session.id)
    OperationService.complete_open_only(db, session.id)

    assert _stock_quantity(db, data["product"].id, data["cell1"].id) == Decimal("5.000")
    assert db.query(StockMovement).count() == 0


def test_lock_controller_failure_marks_session_error_and_does_not_change_stock(db, sample_data):
    data = sample_data()
    failing_lock = MockLockController(fail_next_open=True)

    with pytest.raises(Exception):
        OperationService.start_fill(
            db,
            failing_lock,
            user_id=data["users"]["user"].id,
            product_id=data["product"].id,
            cell_id=data["cell1"].id,
            quantity=Decimal("2.000"),
        )

    assert _stock_quantity(db, data["product"].id, data["cell1"].id) == Decimal("5.000")
    assert db.query(StockMovement).count() == 0
    assert SessionService.get_session(db, 1).status == SessionStatus.ERROR
    event = db.query(AccessEvent).order_by(AccessEvent.id.desc()).first()
    assert event.event_type == AccessEventType.OPEN_CELL_FAILED
