from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.enums import MovementType
from app.models.stock_item import StockItem
from app.models.stock_movement import StockMovement
from app.services.errors import CellProductConflictError, InsufficientStockError


class StockService:
    """Manage current stock rows and movement history."""

    @staticmethod
    def get_stock_item(db: Session, product_id: int, cell_id: int) -> StockItem | None:
        """Return a stock row for a product in a cell.

        Args:
            db: SQLAlchemy session.
            product_id: Product identifier.
            cell_id: Cell identifier.

        Returns:
            Existing stock row, or None when no row exists.
        """
        return db.scalars(
            select(StockItem).where(
                StockItem.product_id == product_id,
                StockItem.cell_id == cell_id,
            )
        ).first()

    @staticmethod
    def ensure_cell_accepts_product(db: Session, product_id: int, cell_id: int) -> None:
        """Ensure a cell has no positive stock for a different product.

        Args:
            db: SQLAlchemy session.
            product_id: Product that is about to be placed in the cell.
            cell_id: Target cell identifier.

        Raises:
            CellProductConflictError: If the cell already contains another product.
        """
        conflicting_item = db.scalars(
            select(StockItem).where(
                StockItem.cell_id == cell_id,
                StockItem.product_id != product_id,
                StockItem.quantity > 0,
            )
        ).first()
        if conflicting_item is not None:
            raise CellProductConflictError(
                "Cell already contains another product: "
                f"cell_id={cell_id} existing_product_id={conflicting_item.product_id}"
            )

    @staticmethod
    def set_current_quantity(
        db: Session,
        product_id: int,
        cell_id: int,
        quantity: Decimal,
    ) -> StockItem | None:
        """Set current stock and remove the row when a cell becomes empty.

        Args:
            db: SQLAlchemy session.
            product_id: Product identifier.
            cell_id: Cell identifier.
            quantity: New current quantity.

        Returns:
            Updated stock row, or None when the quantity is zero and the row was
            removed.
        """
        stock_item = StockService.get_stock_item(db, product_id=product_id, cell_id=cell_id)
        if quantity <= 0:
            if stock_item is not None:
                db.delete(stock_item)
                db.flush()
            return None
        StockService.ensure_cell_accepts_product(db, product_id=product_id, cell_id=cell_id)
        if stock_item is None:
            stock_item = StockItem(product_id=product_id, cell_id=cell_id, quantity=quantity)
            db.add(stock_item)
        else:
            stock_item.quantity = quantity
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
        stock_item = StockService.get_stock_item(db, product_id=product_id, cell_id=cell_id)
        before = stock_item.quantity if stock_item is not None else Decimal("0.000")
        after = before + quantity
        if after > 0:
            StockService.ensure_cell_accepts_product(db, product_id=product_id, cell_id=cell_id)
        StockService.set_current_quantity(db, product_id=product_id, cell_id=cell_id, quantity=after)
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
        stock_item = StockService.get_stock_item(db, product_id=product_id, cell_id=cell_id)
        before = stock_item.quantity if stock_item is not None else Decimal("0.000")
        if before < quantity:
            raise InsufficientStockError(
                f"Not enough stock: product_id={product_id} cell_id={cell_id} available={before}"
            )
        after = before - quantity
        StockService.set_current_quantity(db, product_id=product_id, cell_id=cell_id, quantity=after)
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
        stock_item = StockService.get_stock_item(db, product_id=product_id, cell_id=cell_id)
        before = stock_item.quantity if stock_item is not None else Decimal("0.000")
        StockService.set_current_quantity(
            db,
            product_id=product_id,
            cell_id=cell_id,
            quantity=actual_quantity,
        )
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
