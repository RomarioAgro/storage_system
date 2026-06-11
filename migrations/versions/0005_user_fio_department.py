"""user fio and department

Revision ID: 0005_user_fio_department
Revises: 0004_one_positive_product_per_cell
Create Date: 2026-06-11
"""

from alembic import op
import sqlalchemy as sa

revision = "0005_user_fio_department"
down_revision = "0004_one_positive_product_per_cell"
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Replace users.name with FIO fields and department."""
    with op.batch_alter_table("users") as batch_op:
        batch_op.add_column(sa.Column("last_name", sa.String(length=100), nullable=True))
        batch_op.add_column(sa.Column("first_name", sa.String(length=100), nullable=True))
        batch_op.add_column(sa.Column("middle_name", sa.String(length=100), nullable=True))
        batch_op.add_column(sa.Column("department", sa.String(length=200), nullable=True))

    op.execute("UPDATE users SET first_name = name, last_name = 'Не указано' WHERE first_name IS NULL")

    with op.batch_alter_table("users") as batch_op:
        batch_op.alter_column("last_name", existing_type=sa.String(length=100), nullable=False)
        batch_op.alter_column("first_name", existing_type=sa.String(length=100), nullable=False)
        batch_op.create_index("ix_users_last_name", ["last_name"])
        batch_op.create_index("ix_users_first_name", ["first_name"])
        batch_op.create_index("ix_users_department", ["department"])
        batch_op.drop_index("ix_users_name")
        batch_op.drop_column("name")


def downgrade() -> None:
    """Restore users.name from FIO fields."""
    with op.batch_alter_table("users") as batch_op:
        batch_op.add_column(sa.Column("name", sa.String(length=200), nullable=True))

    op.execute(
        "UPDATE users SET name = trim(last_name || ' ' || first_name || ' ' || coalesce(middle_name, '')) "
        "WHERE name IS NULL"
    )

    with op.batch_alter_table("users") as batch_op:
        batch_op.alter_column("name", existing_type=sa.String(length=200), nullable=False)
        batch_op.create_index("ix_users_name", ["name"])
        batch_op.drop_index("ix_users_department")
        batch_op.drop_index("ix_users_first_name")
        batch_op.drop_index("ix_users_last_name")
        batch_op.drop_column("department")
        batch_op.drop_column("middle_name")
        batch_op.drop_column("first_name")
        batch_op.drop_column("last_name")
