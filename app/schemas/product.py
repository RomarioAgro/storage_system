from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel

from app.schemas.common import OrmModel


class ProductCreate(BaseModel):
    name: str
    sku: str | None = None
    barcode: str | None = None
    unit: str = "pcs"
    external_id: str | None = None
    category_id: int | None = None


class ProductResponse(OrmModel):
    id: int
    name: str
    sku: str | None
    barcode: str | None
    unit: str
    external_id: str | None
    category_id: int | None
    is_active: bool
    created_at: datetime
    updated_at: datetime


class ProductCategoryCreate(BaseModel):
    name: str
    parent_id: int | None = None
    sort_order: int = 0


class ProductCategoryResponse(OrmModel):
    id: int
    name: str
    parent_id: int | None
    sort_order: int
    is_active: bool
    created_at: datetime
    updated_at: datetime


class ProductStockCell(BaseModel):
    cell_id: int
    cell_number: int
    quantity: Decimal


class ProductStockResponse(BaseModel):
    product_id: int
    total_quantity: Decimal
    cells: list[ProductStockCell]


class ProductHistoryItem(BaseModel):
    id: int
    created_at: datetime
    movement_type: str
    cell_id: int
    quantity: Decimal
    quantity_before: Decimal
    quantity_after: Decimal
    user_id: int | None
    session_id: int | None
    comment: str | None
