from decimal import Decimal

from fastapi import APIRouter, Depends, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.core.database import get_db
from app.core.enums import CellStatus, ControllerType
from app.core.config import settings
from app.models import (
    AccessEvent,
    Cell,
    CellSession,
    Controller,
    Product,
    ProductCategory,
    Role,
    StockItem,
    StockMovement,
    User,
)
from app.services.errors import NotFoundError
from app.services.session_service import SessionService
from app.ui.templates import templates

router = APIRouter(prefix="/admin", tags=["admin-ui"], include_in_schema=False)


def _product_admin_context(db: Session) -> dict[str, object]:
    categories = db.scalars(
        select(ProductCategory).order_by(
            ProductCategory.parent_id.asc().nullsfirst(),
            ProductCategory.sort_order.asc(),
            ProductCategory.name.asc(),
        )
    ).all()
    products = db.scalars(select(Product).options(joinedload(Product.category)).order_by(Product.name.asc())).all()
    return {"products": products, "categories": categories}


def _user_admin_context(db: Session) -> dict[str, object]:
    users = db.scalars(select(User).options(joinedload(User.role)).order_by(User.id.asc())).all()
    roles = db.scalars(select(Role).order_by(Role.id.asc())).all()
    return {"users": users, "roles": roles}


def _cell_admin_context(db: Session) -> dict[str, object]:
    controllers = db.scalars(select(Controller).order_by(Controller.id.asc())).all()
    cells = db.scalars(select(Cell).options(joinedload(Cell.controller)).order_by(Cell.number.asc())).all()
    return {
        "controllers": controllers,
        "cells": cells,
        "cell_statuses": list(CellStatus),
    }


def _hardware_admin_context(db: Session) -> dict[str, object]:
    controllers = db.scalars(select(Controller).order_by(Controller.id.asc())).all()
    return {"controllers": controllers}


def _stock_admin_context(db: Session) -> dict[str, object]:
    products = db.scalars(select(Product).options(joinedload(Product.category)).order_by(Product.name.asc())).all()
    cells = db.scalars(select(Cell).options(joinedload(Cell.controller)).order_by(Cell.number.asc())).all()
    stock_items = db.scalars(
        select(StockItem)
        .options(joinedload(StockItem.product), joinedload(StockItem.cell))
        .order_by(StockItem.cell_id.asc(), StockItem.product_id.asc())
    ).all()
    return {
        "products": products,
        "cells": cells,
        "stock_items": stock_items,
    }


def _logs_admin_context(db: Session) -> dict[str, object]:
    movements = db.scalars(select(StockMovement).order_by(StockMovement.created_at.desc()).limit(50)).all()
    events = db.scalars(select(AccessEvent).order_by(AccessEvent.created_at.desc()).limit(50)).all()
    sessions = db.scalars(select(CellSession).order_by(CellSession.created_at.desc()).limit(50)).all()
    return {
        "movements": movements,
        "events": events,
        "sessions": sessions,
        "local_timezone": settings.local_timezone,
    }


@router.get("", response_class=HTMLResponse)
def admin_home(request: Request, db: Session = Depends(get_db)) -> HTMLResponse:
    """Show minimal admin panel with operational tables."""
    active_session = SessionService.get_active_session(db)
    return templates.TemplateResponse(
        request,
        "admin/index.html",
        {
            "active_session": active_session,
            "cell_statuses": list(CellStatus),
            "controller_types": list(ControllerType),
        },
    )


@router.get("/users", response_class=HTMLResponse)
def admin_users(request: Request, db: Session = Depends(get_db)) -> HTMLResponse:
    """Show user management in a separate admin tab."""
    return templates.TemplateResponse(
        request,
        "admin/users.html",
        _user_admin_context(db),
    )


@router.get("/products", response_class=HTMLResponse)
def admin_products(request: Request, db: Session = Depends(get_db)) -> HTMLResponse:
    """Show product and product category management in a separate admin tab."""
    return templates.TemplateResponse(
        request,
        "admin/products.html",
        _product_admin_context(db),
    )


@router.get("/cells", response_class=HTMLResponse)
def admin_cells(request: Request, db: Session = Depends(get_db)) -> HTMLResponse:
    """Show cell management in a separate admin tab."""
    return templates.TemplateResponse(
        request,
        "admin/cells.html",
        _cell_admin_context(db),
    )


@router.get("/hardware", response_class=HTMLResponse)
def admin_hardware(request: Request, db: Session = Depends(get_db)) -> HTMLResponse:
    """Show hardware controllers in a separate admin tab."""
    return templates.TemplateResponse(
        request,
        "admin/hardware.html",
        _hardware_admin_context(db),
    )


@router.get("/stock", response_class=HTMLResponse)
def admin_stock(request: Request, db: Session = Depends(get_db)) -> HTMLResponse:
    """Show stock rows in a separate admin tab."""
    return templates.TemplateResponse(
        request,
        "admin/stock.html",
        _stock_admin_context(db),
    )


@router.get("/logs", response_class=HTMLResponse)
def admin_logs(request: Request, db: Session = Depends(get_db)) -> HTMLResponse:
    """Show movements, access events, and cell sessions in a separate admin tab."""
    return templates.TemplateResponse(
        request,
        "admin/logs.html",
        _logs_admin_context(db),
    )


@router.post("/users", response_class=HTMLResponse)
async def create_user(request: Request, db: Session = Depends(get_db)) -> RedirectResponse:
    """Create a user from the admin MVP form."""
    form = await request.form()
    db.add(
        User(
            name=str(form["name"]).strip(),
            rfid_uid=str(form["rfid_uid"]).strip(),
            role_id=int(form["role_id"]),
            is_active=str(form.get("is_active", "off")) == "on",
        )
    )
    db.commit()
    return RedirectResponse(url="/admin/users#users", status_code=303)


@router.post("/users/{user_id}", response_class=HTMLResponse)
async def update_user(request: Request, user_id: int, db: Session = Depends(get_db)) -> RedirectResponse:
    """Update user fields from the admin MVP form."""
    user = db.get(User, user_id)
    if user is None:
        raise NotFoundError("User not found")
    form = await request.form()
    user.name = str(form["name"]).strip()
    user.rfid_uid = str(form["rfid_uid"]).strip()
    user.role_id = int(form["role_id"])
    user.is_active = str(form.get("is_active", "off")) == "on"
    db.commit()
    return RedirectResponse(url="/admin/users#users", status_code=303)


@router.post("/users/{user_id}/toggle-active", response_class=HTMLResponse)
def toggle_user_active(user_id: int, db: Session = Depends(get_db)) -> RedirectResponse:
    """Block or unblock a user from the admin MVP panel."""
    user = db.get(User, user_id)
    if user is None:
        raise NotFoundError("User not found")
    user.is_active = not user.is_active
    db.commit()
    return RedirectResponse(url="/admin/users#users", status_code=303)


@router.post("/products", response_class=HTMLResponse)
async def create_product(request: Request, db: Session = Depends(get_db)) -> RedirectResponse:
    """Create a product from the admin MVP form."""
    form = await request.form()
    db.add(
        Product(
            name=str(form["name"]).strip(),
            sku=str(form.get("sku") or "").strip() or None,
            barcode=str(form.get("barcode") or "").strip() or None,
            unit=str(form.get("unit") or "pcs").strip(),
            external_id=str(form.get("external_id") or "").strip() or None,
            category_id=int(form["category_id"]) if form.get("category_id") else None,
        )
    )
    db.commit()
    return RedirectResponse(url="/admin/products#products", status_code=303)


@router.post("/categories", response_class=HTMLResponse)
async def create_category(request: Request, db: Session = Depends(get_db)) -> RedirectResponse:
    """Create a product category from the admin MVP form."""
    form = await request.form()
    db.add(
        ProductCategory(
            name=str(form["name"]).strip(),
            parent_id=int(form["parent_id"]) if form.get("parent_id") else None,
            sort_order=int(form.get("sort_order") or 0),
            is_active=str(form.get("is_active", "off")) == "on",
        )
    )
    db.commit()
    return RedirectResponse(url="/admin/products#categories", status_code=303)


@router.post("/categories/{category_id}", response_class=HTMLResponse)
async def update_category(
    request: Request,
    category_id: int,
    db: Session = Depends(get_db),
) -> RedirectResponse:
    """Update a product category from the admin MVP form."""
    category = db.get(ProductCategory, category_id)
    if category is None:
        raise NotFoundError("Product category not found")
    form = await request.form()
    category.name = str(form["name"]).strip()
    category.parent_id = int(form["parent_id"]) if form.get("parent_id") else None
    category.sort_order = int(form.get("sort_order") or 0)
    category.is_active = str(form.get("is_active", "off")) == "on"
    db.commit()
    return RedirectResponse(url="/admin/products#categories", status_code=303)


@router.post("/categories/{category_id}/toggle-active", response_class=HTMLResponse)
def toggle_category_active(category_id: int, db: Session = Depends(get_db)) -> RedirectResponse:
    """Activate or deactivate a product category."""
    category = db.get(ProductCategory, category_id)
    if category is None:
        raise NotFoundError("Product category not found")
    category.is_active = not category.is_active
    db.commit()
    return RedirectResponse(url="/admin/products#categories", status_code=303)


@router.post("/cells", response_class=HTMLResponse)
async def create_cell(request: Request, db: Session = Depends(get_db)) -> RedirectResponse:
    """Create a cell from the admin MVP form."""
    form = await request.form()
    db.add(
        Cell(
            number=int(form["number"]),
            status=CellStatus(str(form["status"])),
            controller_id=int(form["controller_id"]) if form.get("controller_id") else None,
            controller_address=int(form["controller_address"]) if form.get("controller_address") else None,
            relay_channel=int(form["relay_channel"]) if form.get("relay_channel") else None,
            has_close_sensor=str(form.get("has_close_sensor", "off")) == "on",
            comment=str(form.get("comment") or "").strip() or None,
        )
    )
    db.commit()
    return RedirectResponse(url="/admin/cells#cells", status_code=303)


@router.post("/cells/{cell_id}", response_class=HTMLResponse)
async def update_cell(request: Request, cell_id: int, db: Session = Depends(get_db)) -> RedirectResponse:
    """Update cell fields from the admin MVP form."""
    cell = db.get(Cell, cell_id)
    if cell is None:
        raise NotFoundError("Cell not found")
    form = await request.form()
    cell.number = int(form["number"])
    cell.status = CellStatus(str(form["status"]))
    cell.controller_id = int(form["controller_id"]) if form.get("controller_id") else None
    cell.controller_address = int(form["controller_address"]) if form.get("controller_address") else None
    cell.relay_channel = int(form["relay_channel"]) if form.get("relay_channel") else None
    cell.has_close_sensor = str(form.get("has_close_sensor", "off")) == "on"
    cell.comment = str(form.get("comment") or "").strip() or None
    db.commit()
    return RedirectResponse(url="/admin/cells#cells", status_code=303)


@router.post("/cells/{cell_id}/toggle-block", response_class=HTMLResponse)
def toggle_cell_block(cell_id: int, db: Session = Depends(get_db)) -> RedirectResponse:
    """Block or unblock a storage cell from the admin MVP panel."""
    cell = db.get(Cell, cell_id)
    if cell is None:
        raise NotFoundError("Cell not found")
    cell.status = CellStatus.ACTIVE if cell.status == CellStatus.BLOCKED else CellStatus.BLOCKED
    db.commit()
    return RedirectResponse(url="/admin/cells#cells", status_code=303)


@router.post("/stock", response_class=HTMLResponse)
async def create_stock_item(request: Request, db: Session = Depends(get_db)) -> RedirectResponse:
    """Create initial stock row from the admin MVP form."""
    form = await request.form()
    db.add(
        StockItem(
            product_id=int(form["product_id"]),
            cell_id=int(form["cell_id"]),
            quantity=Decimal(str(form["quantity"])),
        )
    )
    db.commit()
    return RedirectResponse(url="/admin/stock#stock", status_code=303)


@router.post("/sessions/{session_id}/emergency-cancel", response_class=HTMLResponse)
async def emergency_cancel(request: Request, session_id: int, db: Session = Depends(get_db)) -> RedirectResponse:
    """Emergency-cancel an active session from admin panel."""
    form = await request.form()
    reason = str(form.get("reason") or "Emergency admin cancellation")
    SessionService.cancel(db, session_id=session_id, reason=reason)
    return RedirectResponse(url="/admin/logs#sessions", status_code=303)
