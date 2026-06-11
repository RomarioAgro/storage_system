from decimal import Decimal

from app.core.enums import MovementType, SessionStatus
from app.models.stock_item import StockItem
from app.models.stock_movement import StockMovement
from app.services.operation_service import OperationService
from app.services.session_service import SessionService


def test_inventory_uses_session_lifecycle_before_changing_stock(db, mock_lock_controller, sample_data):
    data = sample_data()

    session = OperationService.start_inventory(
        db,
        mock_lock_controller,
        user_id=data["users"]["manager"].id,
        product_id=data["product"].id,
        cell_id=data["cell1"].id,
        actual_quantity=Decimal("11.000"),
    )

    stock = db.query(StockItem).filter_by(product_id=data["product"].id, cell_id=data["cell1"].id).one()
    assert session.status == SessionStatus.WAITING_CLOSE
    assert stock.quantity == Decimal("5.000")

    SessionService.confirm_close(db, session.id)
    assert stock.quantity == Decimal("5.000")

    OperationService.confirm_inventory(db, session.id)
    db.refresh(stock)
    assert stock.quantity == Decimal("11.000")
    movement = db.query(StockMovement).one()
    assert movement.movement_type == MovementType.INVENTORY
    assert movement.session_id == session.id
    assert movement.quantity_before == Decimal("5.000")
    assert movement.quantity_after == Decimal("11.000")


def test_inventory_zero_count_removes_stock_item_row(db, mock_lock_controller, sample_data):
    data = sample_data()

    session = OperationService.start_inventory(
        db,
        mock_lock_controller,
        user_id=data["users"]["manager"].id,
        product_id=data["product"].id,
        cell_id=data["cell1"].id,
        actual_quantity=Decimal("0.000"),
    )

    SessionService.confirm_close(db, session.id)
    OperationService.confirm_inventory(db, session.id)

    assert (
        db.query(StockItem)
        .filter_by(product_id=data["product"].id, cell_id=data["cell1"].id)
        .count()
        == 0
    )
    movement = db.query(StockMovement).one()
    assert movement.quantity_before == Decimal("5.000")
    assert movement.quantity_after == Decimal("0.000")
