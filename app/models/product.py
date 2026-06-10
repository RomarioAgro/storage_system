from sqlalchemy import Boolean, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, created_at_col, updated_at_col


class Product(Base):
    __tablename__ = "products"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(300), index=True)
    sku: Mapped[str | None] = mapped_column(String(100), unique=True, index=True, nullable=True)
    barcode: Mapped[str | None] = mapped_column(String(100), unique=True, index=True, nullable=True)
    unit: Mapped[str] = mapped_column(String(20), default="pcs")
    external_id: Mapped[str | None] = mapped_column(String(100), unique=True, index=True, nullable=True)
    category_id: Mapped[int | None] = mapped_column(
        ForeignKey("product_categories.id"),
        nullable=True,
        index=True,
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[created_at_col]
    updated_at: Mapped[updated_at_col]

    stock_items = relationship("StockItem", back_populates="product")
    movements = relationship("StockMovement", back_populates="product")
    category = relationship("ProductCategory", back_populates="products")
