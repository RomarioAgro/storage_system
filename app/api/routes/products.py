from decimal import Decimal

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.cell import Cell
from app.models.product import Product
from app.models.product_category import ProductCategory
from app.models.stock_item import StockItem
from app.models.stock_movement import StockMovement
from app.schemas.product import (
    ProductCreate,
    ProductCategoryCreate,
    ProductCategoryResponse,
    ProductHistoryItem,
    ProductResponse,
    ProductStockCell,
    ProductStockResponse,
)
from app.services.errors import NotFoundError

router = APIRouter()


@router.get("", response_model=list[ProductResponse])
def search_products(
    query: str = Query(default="", description="Barcode, SKU, or name fragment"),
    category_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
) -> list[Product]:
    q = query.strip()
    statement = select(Product).where(Product.is_active.is_(True))
    if category_id is not None:
        statement = statement.where(Product.category_id == category_id)
    if q:
        barcode_match = db.scalars(statement.where(Product.barcode == q)).all()
        if barcode_match:
            return list(barcode_match)
        sku_match = db.scalars(statement.where(Product.sku == q)).all()
        if sku_match:
            return list(sku_match)
        statement = statement.where(Product.name.ilike(f"%{q}%"))
    return list(db.scalars(statement.order_by(Product.name.asc()).limit(50)).all())


@router.post("", response_model=ProductResponse)
def create_product(payload: ProductCreate, db: Session = Depends(get_db)) -> Product:
    if payload.category_id is not None and db.get(ProductCategory, payload.category_id) is None:
        raise NotFoundError("Product category not found")
    product = Product(**payload.model_dump())
    db.add(product)
    db.commit()
    db.refresh(product)
    return product


@router.get("/categories", response_model=list[ProductCategoryResponse])
def list_categories(db: Session = Depends(get_db)) -> list[ProductCategory]:
    return list(
        db.scalars(
            select(ProductCategory)
            .where(ProductCategory.is_active.is_(True))
            .order_by(
                ProductCategory.parent_id.asc().nullsfirst(),
                ProductCategory.sort_order.asc(),
                ProductCategory.name.asc(),
            )
        ).all()
    )


@router.post("/categories", response_model=ProductCategoryResponse)
def create_category(payload: ProductCategoryCreate, db: Session = Depends(get_db)) -> ProductCategory:
    if payload.parent_id is not None and db.get(ProductCategory, payload.parent_id) is None:
        raise NotFoundError("Parent product category not found")
    category = ProductCategory(**payload.model_dump())
    db.add(category)
    db.commit()
    db.refresh(category)
    return category


@router.get("/{product_id}/stock", response_model=ProductStockResponse)
def get_product_stock(product_id: int, db: Session = Depends(get_db)) -> ProductStockResponse:
    product = db.get(Product, product_id)
    if product is None:
        raise NotFoundError("Product not found")
    rows = db.execute(
        select(StockItem.cell_id, Cell.number, StockItem.quantity)
        .join(Cell, Cell.id == StockItem.cell_id)
        .where(StockItem.product_id == product_id, StockItem.quantity > 0)
        .order_by(Cell.number.asc())
    ).all()
    cells = [
        ProductStockCell(cell_id=row.cell_id, cell_number=row.number, quantity=row.quantity)
        for row in rows
    ]
    total = db.scalar(
        select(func.coalesce(func.sum(StockItem.quantity), Decimal("0.000"))).where(
            StockItem.product_id == product_id
        )
    )
    return ProductStockResponse(product_id=product_id, total_quantity=total, cells=cells)


@router.get("/{product_id}/history", response_model=list[ProductHistoryItem])
def get_product_history(product_id: int, db: Session = Depends(get_db)) -> list[ProductHistoryItem]:
    product = db.get(Product, product_id)
    if product is None:
        raise NotFoundError("Product not found")
    movements = db.scalars(
        select(StockMovement)
        .where(StockMovement.product_id == product_id)
        .order_by(StockMovement.created_at.desc())
        .limit(100)
    ).all()
    return [
        ProductHistoryItem(
            id=m.id,
            created_at=m.created_at,
            movement_type=m.movement_type.value,
            cell_id=m.cell_id,
            quantity=m.quantity,
            quantity_before=m.quantity_before,
            quantity_after=m.quantity_after,
            user_id=m.user_id,
            session_id=m.session_id,
            comment=m.comment,
        )
        for m in movements
    ]
