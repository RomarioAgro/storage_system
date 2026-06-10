from decimal import Decimal

import pytest
from sqlalchemy.exc import IntegrityError

from app.core.enums import SessionOperationType, SessionStatus
from app.models.cell_session import CellSession
from app.models.stock_item import StockItem


def test_db_rejects_second_active_session(db, sample_data):
    data = sample_data()
    user = data["users"]["user"]
    first = CellSession(
        user_id=user.id,
        cell_id=data["cell1"].id,
        operation_type=SessionOperationType.OPEN_ONLY,
        status=SessionStatus.WAITING_CLOSE,
    )
    second = CellSession(
        user_id=user.id,
        cell_id=data["cell2"].id,
        operation_type=SessionOperationType.OPEN_ONLY,
        status=SessionStatus.CREATED,
    )

    db.add(first)
    db.flush()
    db.add(second)

    with pytest.raises(IntegrityError):
        db.flush()


def test_stock_items_are_unique_per_cell_and_product(db, sample_data):
    data = sample_data()
    duplicate = StockItem(
        product_id=data["product"].id,
        cell_id=data["cell1"].id,
        quantity=Decimal("1.000"),
    )

    db.add(duplicate)

    with pytest.raises(IntegrityError):
        db.flush()


def test_stock_items_reject_second_positive_product_in_cell(db, sample_data):
    data = sample_data()
    mixed_product = StockItem(
        product_id=data["name_only_product"].id,
        cell_id=data["cell1"].id,
        quantity=Decimal("1.000"),
    )

    db.add(mixed_product)

    with pytest.raises(IntegrityError):
        db.flush()


def test_stock_items_allow_zero_quantity_different_product_in_cell(db, sample_data):
    data = sample_data()
    zero_row = StockItem(
        product_id=data["name_only_product"].id,
        cell_id=data["cell1"].id,
        quantity=Decimal("0.000"),
    )

    db.add(zero_row)
    db.flush()

    assert zero_row.id is not None
