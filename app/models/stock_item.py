from decimal import Decimal

from sqlalchemy import ForeignKey, Integer, Numeric, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, created_at_col, updated_at_col


class StockItem(Base):
    __tablename__ = "stock_items"
    __table_args__ = (UniqueConstraint("cell_id", "product_id", name="uq_stock_cell_product"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    cell_id: Mapped[int] = mapped_column(ForeignKey("cells.id"), index=True)
    product_id: Mapped[int] = mapped_column(ForeignKey("products.id"), index=True)
    quantity: Mapped[Decimal] = mapped_column(Numeric(12, 3), default=Decimal("0.000"))
    created_at: Mapped[created_at_col]
    updated_at: Mapped[updated_at_col]

    cell = relationship("Cell", back_populates="stock_items")
    product = relationship("Product", back_populates="stock_items")
