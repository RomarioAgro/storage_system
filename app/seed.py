import logging
from decimal import Decimal

from sqlalchemy import select

from app.core.database import SessionLocal, engine
from app.core.enums import CellStatus, ControllerType, RoleCode
from app.models import Cell, Controller, Product, ProductCategory, Role, StockItem, User
from app.models.base import Base
from app.services.permission_service import PermissionService

# Ensure metadata is populated for create_all.
import app.models  # noqa: F401

logger = logging.getLogger(__name__)

ROLE_NAMES = {
    RoleCode.ADMIN: "Administrator",
    RoleCode.MANAGER: "Manager",
    RoleCode.USER: "User",
    RoleCode.SERVICE: "Service",
}

PURCHASED_TEST_PRODUCTS = [
    ("Флешка Netac U27 4Gb USB2.0 металлическая", "FLASH-NETAC-U27-4GB", "460202600101", "Накопители"),
    ("Мышь Defender MB-270 PRO", "MOUSE-DEFENDER-MB270", "460202600102", "Периферия"),
    ("Оптическая мышь Azora MB-24", "MOUSE-AZORA-MB24", "460202600103", "Периферия"),
    ("Терминал сбора данных GlobalPOS GP-C6100", "TSD-GLOBALPOS-GPC6100", "460202600104", "ТСД"),
    ("Терминал сбора данных GlobalPOS GP-C5100", "TSD-GLOBALPOS-GPC5100", "460202600105", "ТСД"),
    (
        "Коммуникационно-зарядная подставка GlobalPOS GP-C6100",
        "DOCK-GLOBALPOS-GPC6100",
        "460202600106",
        "Аксессуары ТСД",
    ),
    ("Сканер ШК PayTor FL-1008", "SCANNER-PAYTOR-FL1008", "460202600107", "Сканеры штрихкода"),
    ("Сканер ШК PayTor FL-2008", "SCANNER-PAYTOR-FL2008", "460202600108", "Сканеры штрихкода"),
    (
        "Сканер Mertech SF50 NFC/RFID/P2D",
        "SCANNER-MERTECH-SF50",
        "460202600109",
        "Сканеры штрихкода",
    ),
    (
        "Детектор банкнот DoCash Vega RUB с АКБ",
        "DETECTOR-DOCASH-VEGA",
        "460202600110",
        "Кассовое оборудование",
    ),
    (
        "Точка доступа Ubiquiti UniFi AP AC-PRO",
        "AP-UBIQUITI-ACPRO",
        "460202600111",
        "Сетевое оборудование",
    ),
    (
        "Точка доступа MikroTik cAP ac AC1200",
        "AP-MIKROTIK-CAP-AC",
        "460202600112",
        "Сетевое оборудование",
    ),
    ("Смартфон Realme Note 60x 3/64GB", "PHONE-REALME-NOTE60X-64", "460202600113", "Мобильные устройства"),
    ("SSD Kingston 240GB 2.5 SATA", "SSD-KINGSTON-240-SATA", "460202600114", "Накопители"),
    ("SSD M.2 Kingston 1TB NVMe PCIe Gen4", "SSD-KINGSTON-M2-1TB", "460202600115", "Накопители"),
    ("Печатающая головка Honeywell PC42t", "HEAD-HONEYWELL-PC42T", "460202600116", "Запчасти принтеров"),
    ("Картридж Epson T9452 Cyan", "CART-EPSON-T9452-C", "460202600117", "Картриджи"),
    ("Картридж Epson T9454 Yellow", "CART-EPSON-T9454-Y", "460202600118", "Картриджи"),
    ("Картридж Epson T9453 Magenta", "CART-EPSON-T9453-M", "460202600119", "Картриджи"),
    ("Картридж Ricoh MP C2503H Yellow", "CART-RICOH-MPC2503H-Y", "460202600120", "Картриджи"),
    ("Картридж Ricoh MP C2503 Black", "CART-RICOH-MPC2503-BK", "460202600121", "Картриджи"),
]

PURCHASED_TEST_STOCK = [
    ("FLASH-NETAC-U27-4GB", 2, Decimal("30.000")),
    ("MOUSE-DEFENDER-MB270", 3, Decimal("20.000")),
    ("TSD-GLOBALPOS-GPC6100", 4, Decimal("22.000")),
    ("SCANNER-PAYTOR-FL1008", 5, Decimal("6.000")),
    ("DETECTOR-DOCASH-VEGA", 6, Decimal("9.000")),
    ("AP-UBIQUITI-ACPRO", 7, Decimal("8.000")),
    ("SSD-KINGSTON-240-SATA", 8, Decimal("20.000")),
]


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
        role = Role(
            code=code.value,
            name=ROLE_NAMES[code],
            permissions=sorted(PermissionService.ROLE_ACTIONS[code]),
        )
        db.add(role)
        db.flush()
    elif role.permissions is None:
        role.permissions = sorted(PermissionService.ROLE_ACTIONS[code])
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
        purchased_categories = {
            name: get_or_create_category(db, name, sort_order=30 + index)
            for index, name in enumerate(
                sorted({category_name for _, _, _, category_name in PURCHASED_TEST_PRODUCTS})
            )
        }

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
        for name, sku, barcode, category_name in PURCHASED_TEST_PRODUCTS:
            if db.scalars(select(Product).where(Product.sku == sku)).first() is None:
                db.add(
                    Product(
                        name=name,
                        sku=sku,
                        barcode=barcode,
                        unit="pcs",
                        category_id=purchased_categories[category_name].id,
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
        for sku, cell_number, quantity in PURCHASED_TEST_STOCK:
            product = db.scalars(select(Product).where(Product.sku == sku)).first()
            cell = db.scalars(select(Cell).where(Cell.number == cell_number)).first()
            if product is None or cell is None:
                continue
            existing_cell_stock = db.scalars(
                select(StockItem).where(StockItem.cell_id == cell.id, StockItem.quantity > 0)
            ).first()
            if existing_cell_stock is not None:
                continue
            stock = db.scalars(
                select(StockItem).where(StockItem.product_id == product.id, StockItem.cell_id == cell.id)
            ).first()
            if stock is None:
                db.add(StockItem(product_id=product.id, cell_id=cell.id, quantity=quantity))

        db.commit()
        logger.info("Seed complete")
    finally:
        db.close()


if __name__ == "__main__":
    seed()
