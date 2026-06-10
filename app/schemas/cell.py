from decimal import Decimal

from pydantic import BaseModel

from app.schemas.common import OrmModel


class CellResponse(OrmModel):
    id: int
    number: int
    status: str
    controller_id: int | None
    controller_address: int | None
    relay_channel: int | None
    has_close_sensor: bool
    comment: str | None


class CellContentItem(BaseModel):
    product_id: int
    product_name: str
    sku: str | None
    barcode: str | None
    quantity: Decimal


class CellContentsResponse(BaseModel):
    cell_id: int
    cell_number: int
    items: list[CellContentItem]
