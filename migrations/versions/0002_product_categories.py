"""product categories

Revision ID: 0002_product_categories
Revises: 0001_initial
Create Date: 2026-06-10
"""

from alembic import op
import sqlalchemy as sa

revision = "0002_product_categories"
down_revision = "0001_initial"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "product_categories",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("name", sa.String(length=200), nullable=False),
        sa.Column("parent_id", sa.Integer(), sa.ForeignKey("product_categories.id"), nullable=True),
        sa.Column("sort_order", sa.Integer(), nullable=False, server_default=sa.text("0")),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.UniqueConstraint("name"),
    )
    op.create_index("ix_product_categories_name", "product_categories", ["name"])
    op.create_index("ix_product_categories_parent_id", "product_categories", ["parent_id"])
    with op.batch_alter_table("products") as batch_op:
        batch_op.add_column(
            sa.Column(
                "category_id",
                sa.Integer(),
                sa.ForeignKey("product_categories.id", name="fk_products_category_id_product_categories"),
                nullable=True,
            )
        )
        batch_op.create_index("ix_products_category_id", ["category_id"])


def downgrade() -> None:
    with op.batch_alter_table("products") as batch_op:
        batch_op.drop_index("ix_products_category_id")
        batch_op.drop_column("category_id")
    op.drop_index("ix_product_categories_parent_id", table_name="product_categories")
    op.drop_index("ix_product_categories_name", table_name="product_categories")
    op.drop_table("product_categories")
