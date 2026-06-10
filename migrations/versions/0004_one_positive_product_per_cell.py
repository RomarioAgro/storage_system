"""one positive product per cell

Revision ID: 0004_one_positive_product_per_cell
Revises: 0003_timezone_aware_timestamps
Create Date: 2026-06-10
"""

from alembic import op
import sqlalchemy as sa

revision = "0004_one_positive_product_per_cell"
down_revision = "0003_timezone_aware_timestamps"
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Create a partial unique index that prevents mixed positive stock in one cell."""
    bind = op.get_bind()
    where_clause = sa.text("quantity > 0")
    kwargs = {}
    if bind.dialect.name == "postgresql":
        kwargs["postgresql_where"] = where_clause
    elif bind.dialect.name == "sqlite":
        kwargs["sqlite_where"] = where_clause
    op.create_index(
        "uq_stock_one_positive_product_per_cell",
        "stock_items",
        ["cell_id"],
        unique=True,
        **kwargs,
    )


def downgrade() -> None:
    """Drop the one-positive-product-per-cell index."""
    op.drop_index("uq_stock_one_positive_product_per_cell", table_name="stock_items")
