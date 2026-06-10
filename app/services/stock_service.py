from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.enums import MovementType
from app.models.stock_item import StockItem
from app.models.stock_movement import StockMovement
from app.services.errors import InsufficientStockError


class StockService:
    @staticmethod
    def get_or_create_stock_item(db: Session, product_id: int, cell_id: int) -> StockItem:
        stock_item = db.scalars(
            select(StockItem).where(
                StockItem.product_id == product_id,
                StockItem.cell_id == cell_id,
            )
        ).first()
        if stock_item is None:
            stock_item = StockItem(product_id=product_id, cell_id=cell_id, quantity=Decimal("0.000"))
            db.add(stock_item)
            db.flush()
        return stock_item

    @staticmethod
    def add_quantity(
        db: Session,
        user_id: int,
        product_id: int,
        cell_id: int,
        session_id: int,
        quantity: Decimal,
        movement_type: MovementType,
        comment: str | None = None,
    ) -> StockMovement:
        stock_item = StockService.get_or_create_stock_item(db, product_id=product_id, cell_id=cell_id)
        before = stock_item.quantity
        after = before + quantity
        stock_item.quantity = after
        movement = StockMovement(
            user_id=user_id,
            product_id=product_id,
            cell_id=cell_id,
            session_id=session_id,
            movement_type=movement_type,
            quantity=quantity,
            quantity_before=before,
            quantity_after=after,
            comment=comment,
        )
        db.add(movement)
        db.flush()
        return movement

    @staticmethod
    def subtract_quantity(
        db: Session,
        user_id: int,
        product_id: int,
        cell_id: int,
        session_id: int,
        quantity: Decimal,
        movement_type: MovementType,
        comment: str | None = None,
    ) -> StockMovement:
        stock_item = StockService.get_or_create_stock_item(db, product_id=product_id, cell_id=cell_id)
        before = stock_item.quantity
        if before < quantity:
            raise InsufficientStockError(
                f"Not enough stock: product_id={product_id} cell_id={cell_id} available={before}"
            )
        after = before - quantity
        stock_item.quantity = after
        movement = StockMovement(
            user_id=user_id,
            product_id=product_id,
            cell_id=cell_id,
            session_id=session_id,
            movement_type=movement_type,
            quantity=quantity,
            quantity_before=before,
            quantity_after=after,
            comment=comment,
        )
        db.add(movement)
        db.flush()
        return movement

    @staticmethod
    def set_quantity(
        db: Session,
        user_id: int,
        product_id: int,
        cell_id: int,
        session_id: int | None,
        actual_quantity: Decimal,
        comment: str | None = None,
    ) -> StockMovement:
        stock_item = StockService.get_or_create_stock_item(db, product_id=product_id, cell_id=cell_id)
        before = stock_item.quantity
        stock_item.quantity = actual_quantity
        delta = actual_quantity - before
        movement = StockMovement(
            user_id=user_id,
            product_id=product_id,
            cell_id=cell_id,
            session_id=session_id,
            movement_type=MovementType.INVENTORY,
            quantity=delta,
            quantity_before=before,
            quantity_after=actual_quantity,
            comment=comment,
        )
        db.add(movement)
        db.flush()
        return movement
