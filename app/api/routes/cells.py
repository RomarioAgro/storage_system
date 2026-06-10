from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.core.database import get_db
from app.models.cell import Cell
from app.models.stock_item import StockItem
from app.schemas.cell import CellContentItem, CellContentsResponse, CellResponse
from app.services.errors import NotFoundError

router = APIRouter()


@router.get("", response_model=list[CellResponse])
def list_cells(db: Session = Depends(get_db)) -> list[Cell]:
    return list(db.scalars(select(Cell).order_by(Cell.number.asc())).all())


@router.get("/{cell_id}/contents", response_model=CellContentsResponse)
def get_cell_contents(cell_id: int, db: Session = Depends(get_db)) -> CellContentsResponse:
    cell = db.get(Cell, cell_id)
    if cell is None:
        raise NotFoundError("Cell not found")
    rows = db.scalars(
        select(StockItem)
        .options(joinedload(StockItem.product))
        .where(StockItem.cell_id == cell_id, StockItem.quantity > 0)
        .order_by(StockItem.product_id.asc())
    ).all()
    return CellContentsResponse(
        cell_id=cell.id,
        cell_number=cell.number,
        items=[
            CellContentItem(
                product_id=row.product_id,
                product_name=row.product.name,
                sku=row.product.sku,
                barcode=row.product.barcode,
                quantity=row.quantity,
            )
            for row in rows
        ],
    )
