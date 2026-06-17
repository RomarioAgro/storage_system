from sqlalchemy import select
from sqlalchemy.orm import sessionmaker

from app import seed as seed_module
from app.models import Product, StockItem


def test_seed_adds_purchase_products_without_duplicates(engine, monkeypatch):
    """Seed imported purchase products and remains safe to run twice.

    Args:
        engine: Test database engine.
        monkeypatch: Pytest monkeypatch fixture.
    """
    monkeypatch.setattr(seed_module, "engine", engine)
    monkeypatch.setattr(seed_module, "SessionLocal", sessionmaker(bind=engine, future=True))

    seed_module.seed()
    seed_module.seed()

    Session = sessionmaker(bind=engine, future=True)
    with Session() as db:
        products = db.scalars(select(Product).where(Product.sku.like("FLASH-NETAC%"))).all()
        assert len(products) == 1
        assert products[0].category is not None
        assert products[0].category.name == "Накопители"

        stock_rows = db.scalars(select(StockItem).join(Product).where(Product.sku == "FLASH-NETAC-U27-4GB")).all()
        assert len(stock_rows) == 1
        assert stock_rows[0].quantity == 30
