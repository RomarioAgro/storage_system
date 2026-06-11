import logging
from decimal import Decimal

from sqlalchemy import select

from app.core.database import SessionLocal, engine
from app.core.enums import CellStatus, ControllerType, RoleCode
from app.models import Cell, Controller, Product, ProductCategory, Role, StockItem, User
from app.models.base import Base

# Ensure metadata is populated for create_all.
import app.models  # noqa: F401

logger = logging.getLogger(__name__)

ROLE_NAMES = {
    RoleCode.ADMIN: "Administrator",
    RoleCode.MANAGER: "Manager",
    RoleCode.USER: "User",
    RoleCode.SERVICE: "Service",
}


def get_or_create_role(db, code: RoleCode) -> Role:
    """Return an existing role or create it.

    Args:
        db: SQLAlchemy session.
        code: Role code to find or create.

    Returns:
        Existing or newly created role.
    """
    role = db.scalars(select(Role).where(Role.code == code)).first()
    if role is None:
        role = Role(code=code, name=ROLE_NAMES[code])
        db.add(role)
        db.flush()
    return role


def get_or_create_category(
    db,
    name: str,
    parent: ProductCategory | None = None,
    sort_order: int = 0,
) -> ProductCategory:
    """Return an existing category or create it.

    Args:
        db: SQLAlchemy session.
        name: Category name.
        parent: Optional parent category.
        sort_order: Display ordering number.

    Returns:
        Existing or newly created category.
    """
    category = db.scalars(select(ProductCategory).where(ProductCategory.name == name)).first()
    if category is None:
        category = ProductCategory(name=name, parent_id=parent.id if parent else None, sort_order=sort_order)
        db.add(category)
        db.flush()
    return category


def seed() -> None:
    """Create repeatable local development seed data.

    Side effects:
        Creates tables when needed and inserts roles, users, controller, cells,
        products, and starter stock rows without duplicating existing rows.
    """
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        roles = {code: get_or_create_role(db, code) for code in RoleCode}

        users = [
            ("Админов", "Админ", None, "Администрация", "admin-card", roles[RoleCode.ADMIN]),
            ("Менеджеров", "Менеджер", None, "Склад", "manager-card", roles[RoleCode.MANAGER]),
            ("Пользов", "Пользователь", None, "Производство", "user-card", roles[RoleCode.USER]),
            ("Сервисов", "Сервис", None, "Сервис", "service-card", roles[RoleCode.SERVICE]),
        ]
        for last_name, first_name, middle_name, department, rfid_uid, role in users:
            if db.scalars(select(User).where(User.rfid_uid == rfid_uid)).first() is None:
                db.add(
                    User(
                        last_name=last_name,
                        first_name=first_name,
                        middle_name=middle_name,
                        department=department,
                        rfid_uid=rfid_uid,
                        role_id=role.id,
                    )
                )

        controller = db.scalars(select(Controller).where(Controller.name == "Mock controller 1")).first()
        if controller is None:
            controller = Controller(
                name="Mock controller 1",
                controller_type=ControllerType.MOCK,
                address=1,
                port=None,
                comment="Development controller",
            )
            db.add(controller)
            db.flush()

        for number in range(1, 9):
            if db.scalars(select(Cell).where(Cell.number == number)).first() is None:
                db.add(
                    Cell(
                        number=number,
                        status=CellStatus.ACTIVE,
                        controller_id=controller.id,
                        controller_address=1,
                        relay_channel=number,
                        has_close_sensor=False,
                    )
                )

        consumables = get_or_create_category(db, "Расходники", sort_order=10)
        batteries = get_or_create_category(db, "Батарейки", parent=consumables, sort_order=10)
        cables = get_or_create_category(db, "Кабели", sort_order=20)

        products = [
            ("Кабель HDMI 2м", "HDMI-2M", "460000000001", "pcs", cables),
            ("Батарейка AA", "BAT-AA", "460000000002", "pcs", batteries),
            ("USB-C кабель", "USBC-CABLE", "460000000003", "pcs", cables),
        ]
        for name, sku, barcode, unit, category in products:
            if db.scalars(select(Product).where(Product.sku == sku)).first() is None:
                db.add(
                    Product(
                        name=name,
                        sku=sku,
                        barcode=barcode,
                        unit=unit,
                        category_id=category.id,
                    )
                )

        db.flush()
        product = db.scalars(select(Product).where(Product.sku == "HDMI-2M")).first()
        cell = db.scalars(select(Cell).where(Cell.number == 1)).first()
        if product and cell:
            stock = db.scalars(
                select(StockItem).where(StockItem.product_id == product.id, StockItem.cell_id == cell.id)
            ).first()
            if stock is None:
                db.add(
                    StockItem(
                        product_id=product.id,
                        cell_id=cell.id,
                        quantity=Decimal("3.000"),
                    )
                )

        db.commit()
        logger.info("Seed complete")
    finally:
        db.close()


if __name__ == "__main__":
    seed()
