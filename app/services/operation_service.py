from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.core.config import settings
from app.core.enums import (
    AccessEventType,
    CellStatus,
    EventResult,
    MovementType,
    SessionOperationType,
    SessionStatus,
)
from app.hardware.lock_controller import LockController, LockControllerError
from app.models.cell import Cell
from app.models.cell_session import CellSession
from app.models.product import Product
from app.models.user import User
from app.services.access_log_service import AccessLogService
from app.services.errors import InsufficientStockError, InvalidSessionStateError, NotFoundError
from app.services.permission_service import PermissionService
from app.services.session_service import SessionService
from app.services.stock_service import StockService


class OperationService:
    @staticmethod
    def _get_user(db: Session, user_id: int) -> User:
        user = db.scalars(select(User).options(joinedload(User.role)).where(User.id == user_id)).first()
        if not user or not user.is_active:
            raise NotFoundError("Active user not found")
        return user

    @staticmethod
    def _get_cell(db: Session, cell_id: int) -> Cell:
        cell = db.get(Cell, cell_id)
        if not cell or cell.status != CellStatus.ACTIVE:
            raise NotFoundError("Active cell not found")
        return cell

    @staticmethod
    def _get_product(db: Session, product_id: int) -> Product:
        product = db.get(Product, product_id)
        if not product or not product.is_active:
            raise NotFoundError("Active product not found")
        return product

    @staticmethod
    def _open_lock(
        db: Session,
        lock_controller: LockController,
        session: CellSession,
        cell: Cell,
        client_ip: str | None = None,
    ) -> None:
        SessionService.mark_opening(db, session)
        db.commit()
        db.refresh(session)

        try:
            if cell.controller_address is None or cell.relay_channel is None:
                raise LockControllerError("Cell has no lock controller mapping configured")
            lock_controller.open_cell(
                controller_address=cell.controller_address,
                relay_channel=cell.relay_channel,
                pulse_seconds=settings.lock_pulse_seconds,
            )
            SessionService.mark_opened(db, session)
            AccessLogService.log(
                db,
                event_type=AccessEventType.OPEN_CELL_SUCCESS,
                result=EventResult.OK,
                user_id=session.user_id,
                cell_id=cell.id,
                session_id=session.id,
                client_ip=client_ip,
            )
            db.commit()
        except Exception as exc:
            session.status = SessionStatus.ERROR
            AccessLogService.log(
                db,
                event_type=AccessEventType.OPEN_CELL_FAILED,
                result=EventResult.ERROR,
                user_id=session.user_id,
                cell_id=cell.id,
                session_id=session.id,
                details=str(exc),
                client_ip=client_ip,
            )
            db.commit()
            raise

    @classmethod
    def start_fill(
        cls,
        db: Session,
        lock_controller: LockController,
        user_id: int,
        product_id: int,
        cell_id: int,
        quantity: Decimal,
        comment: str | None = None,
        client_ip: str | None = None,
    ) -> CellSession:
        user = cls._get_user(db, user_id)
        PermissionService.require(user, "fill")
        product = cls._get_product(db, product_id)
        cell = cls._get_cell(db, cell_id)
        if quantity > 0:
            StockService.ensure_cell_accepts_product(db, product_id=product.id, cell_id=cell.id)
        session = SessionService.create_session(
            db,
            user=user,
            cell=cell,
            operation_type=SessionOperationType.FILL,
            product_id=product.id,
            planned_quantity=quantity,
            comment=comment,
            client_ip=client_ip,
        )
        cls._open_lock(db, lock_controller, session, cell, client_ip=client_ip)
        db.commit()
        db.refresh(session)
        return session

    @classmethod
    def confirm_fill(
        cls,
        db: Session,
        session_id: int,
        comment: str | None = None,
        client_ip: str | None = None,
    ) -> CellSession:
        session = SessionService.get_session(db, session_id)
        if session.operation_type != SessionOperationType.FILL:
            raise InvalidSessionStateError("Session is not a fill operation")
        if session.status != SessionStatus.CLOSE_CONFIRMED:
            raise InvalidSessionStateError("Close must be confirmed before stock can be changed")
        if session.product_id is None or session.planned_quantity is None:
            raise InvalidSessionStateError("Fill session has no product or quantity")
        StockService.add_quantity(
            db,
            user_id=session.user_id,
            product_id=session.product_id,
            cell_id=session.cell_id,
            session_id=session.id,
            quantity=session.planned_quantity,
            movement_type=MovementType.FILL,
            comment=comment,
        )
        SessionService.complete(db, session, client_ip=client_ip)
        db.commit()
        db.refresh(session)
        return session

    @classmethod
    def start_take(
        cls,
        db: Session,
        lock_controller: LockController,
        user_id: int,
        product_id: int,
        cell_id: int,
        quantity: Decimal,
        comment: str | None = None,
        client_ip: str | None = None,
    ) -> CellSession:
        user = cls._get_user(db, user_id)
        PermissionService.require(user, "take")
        product = cls._get_product(db, product_id)
        cell = cls._get_cell(db, cell_id)
        stock_item = StockService.get_stock_item(db, product.id, cell.id)
        if stock_item is None or stock_item.quantity < quantity:
            raise InsufficientStockError("Not enough stock in selected cell")
        session = SessionService.create_session(
            db,
            user=user,
            cell=cell,
            operation_type=SessionOperationType.TAKE,
            product_id=product.id,
            planned_quantity=quantity,
            comment=comment,
            client_ip=client_ip,
        )
        cls._open_lock(db, lock_controller, session, cell, client_ip=client_ip)
        db.commit()
        db.refresh(session)
        return session

    @classmethod
    def confirm_take(
        cls,
        db: Session,
        session_id: int,
        comment: str | None = None,
        client_ip: str | None = None,
    ) -> CellSession:
        session = SessionService.get_session(db, session_id)
        if session.operation_type != SessionOperationType.TAKE:
            raise InvalidSessionStateError("Session is not a take operation")
        if session.status != SessionStatus.CLOSE_CONFIRMED:
            raise InvalidSessionStateError("Close must be confirmed before stock can be changed")
        if session.product_id is None or session.planned_quantity is None:
            raise InvalidSessionStateError("Take session has no product or quantity")
        StockService.subtract_quantity(
            db,
            user_id=session.user_id,
            product_id=session.product_id,
            cell_id=session.cell_id,
            session_id=session.id,
            quantity=session.planned_quantity,
            movement_type=MovementType.TAKE,
            comment=comment,
        )
        SessionService.complete(db, session, client_ip=client_ip)
        db.commit()
        db.refresh(session)
        return session

    @classmethod
    def start_open_only(
        cls,
        db: Session,
        lock_controller: LockController,
        user_id: int,
        cell_id: int,
        comment: str | None = None,
        client_ip: str | None = None,
    ) -> CellSession:
        user = cls._get_user(db, user_id)
        PermissionService.require(user, "open_only")
        cell = cls._get_cell(db, cell_id)
        session = SessionService.create_session(
            db,
            user=user,
            cell=cell,
            operation_type=SessionOperationType.OPEN_ONLY,
            comment=comment,
            client_ip=client_ip,
        )
        cls._open_lock(db, lock_controller, session, cell, client_ip=client_ip)
        db.commit()
        db.refresh(session)
        return session

    @classmethod
    def complete_open_only(
        cls,
        db: Session,
        session_id: int,
        client_ip: str | None = None,
    ) -> CellSession:
        session = SessionService.get_session(db, session_id)
        if session.operation_type != SessionOperationType.OPEN_ONLY:
            raise InvalidSessionStateError("Session is not open_only")
        if session.status != SessionStatus.CLOSE_CONFIRMED:
            raise InvalidSessionStateError("Close must be confirmed before completion")
        SessionService.complete(db, session, client_ip=client_ip)
        db.commit()
        db.refresh(session)
        return session

    @classmethod
    def start_inventory(
        cls,
        db: Session,
        lock_controller: LockController,
        user_id: int,
        product_id: int,
        cell_id: int,
        actual_quantity: Decimal,
        comment: str | None = None,
        client_ip: str | None = None,
    ) -> CellSession:
        """Start inventory operation and open a cell through LockController.

        Args:
            db: SQLAlchemy session.
            lock_controller: Hardware abstraction used to open the lock.
            user_id: User performing inventory.
            product_id: Product being counted.
            cell_id: Cell being inventoried.
            actual_quantity: Quantity counted by the user after opening.
            comment: Optional operation comment.

        Returns:
            Created cell session in waiting-close state.
        """
        user = cls._get_user(db, user_id)
        PermissionService.require(user, "inventory")
        product = cls._get_product(db, product_id)
        cell = cls._get_cell(db, cell_id)
        if actual_quantity > 0:
            StockService.ensure_cell_accepts_product(db, product_id=product.id, cell_id=cell.id)
        session = SessionService.create_session(
            db,
            user=user,
            cell=cell,
            operation_type=SessionOperationType.INVENTORY,
            product_id=product.id,
            planned_quantity=actual_quantity,
            comment=comment,
            client_ip=client_ip,
        )
        cls._open_lock(db, lock_controller, session, cell, client_ip=client_ip)
        db.commit()
        db.refresh(session)
        return session

    @classmethod
    def confirm_inventory(
        cls,
        db: Session,
        session_id: int,
        comment: str | None = None,
        client_ip: str | None = None,
    ) -> CellSession:
        """Confirm inventory after cell close and set stock to counted quantity.

        Args:
            db: SQLAlchemy session.
            session_id: Inventory session identifier.
            comment: Optional movement comment.

        Returns:
            Completed inventory session.

        Raises:
            InvalidSessionStateError: If the session is not ready for inventory confirmation.
        """
        session = SessionService.get_session(db, session_id)
        if session.operation_type != SessionOperationType.INVENTORY:
            raise InvalidSessionStateError("Session is not an inventory operation")
        if session.status != SessionStatus.CLOSE_CONFIRMED:
            raise InvalidSessionStateError("Close must be confirmed before inventory can be applied")
        if session.product_id is None or session.planned_quantity is None:
            raise InvalidSessionStateError("Inventory session has no product or quantity")
        StockService.set_quantity(
            db,
            user_id=session.user_id,
            product_id=session.product_id,
            cell_id=session.cell_id,
            session_id=session.id,
            actual_quantity=session.planned_quantity,
            comment=comment,
        )
        SessionService.complete(db, session, client_ip=client_ip)
        db.commit()
        db.refresh(session)
        return session
