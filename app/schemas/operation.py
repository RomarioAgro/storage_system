from decimal import Decimal

from pydantic import BaseModel, Field


class FillStartRequest(BaseModel):
    user_id: int
    product_id: int
    cell_id: int
    quantity: Decimal = Field(gt=Decimal("0.000"))
    comment: str | None = None


class TakeStartRequest(BaseModel):
    user_id: int
    product_id: int
    cell_id: int
    quantity: Decimal = Field(gt=Decimal("0.000"))
    comment: str | None = None


class OpenOnlyStartRequest(BaseModel):
    user_id: int
    cell_id: int
    comment: str | None = None


class ConfirmOperationRequest(BaseModel):
    comment: str | None = None


class InventorySetRequest(BaseModel):
    user_id: int
    product_id: int
    cell_id: int
    actual_quantity: Decimal = Field(ge=Decimal("0.000"))
    comment: str | None = None


class InventoryStartRequest(BaseModel):
    user_id: int
    product_id: int
    cell_id: int
    actual_quantity: Decimal = Field(ge=Decimal("0.000"))
    comment: str | None = None
