from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


class OrmModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class MessageResponse(BaseModel):
    message: str


class QuantityField(BaseModel):
    quantity: Decimal = Field(gt=Decimal("0.000"))
