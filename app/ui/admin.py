from decimal import Decimal
from urllib.parse import urlencode

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
from app.services.stock_service import StockService
from app.ui.templates import templates

router = APIRouter(prefix="/admin", tags=["admin-ui"], include_in_schema=False)

ADMIN_PAGE_SIZE_OPTIONS = (10, 20, 50)
PRODUCT_SORTS = {"id", "name", "category", "sku", "barcode", "unit", "is_active"}
CATEGORY_SORTS = {"id", "name", "parent", "sort_order", "is_active"}


def _contains(value: object, needle: str) -> bool:
    """Return True when a stringified value contains the requested text."""
    return needle.lower() in str(value or "").lower()


def _admin_pagination(rows: list[object], page: int, page_size: int) -> tuple[list[object], dict[str, object]]:
    """Return a bounded page slice and pagination metadata."""
    size = page_size if page_size in ADMIN_PAGE_SIZE_OPTIONS else ADMIN_PAGE_SIZE_OPTIONS[0]
    total = len(rows)
    total_pages = max((total + size - 1) // size, 1)
    normalized_page = min(max(page, 1), total_pages)
    start = (normalized_page - 1) * size
    return rows[start : start + size], {
        "page": normalized_page,
        "page_size": size,
        "page_size_options": list(ADMIN_PAGE_SIZE_OPTIONS),
        "total": total,
        "total_pages": total_pages,
    }


def _admin_url(request: Request, **overrides: object) -> str:
    """Build an admin products URL while preserving existing query parameters."""
    params = dict(request.query_params)
    for key, value in overrides.items():
        if value is None or value == "":
            params.pop(key, None)
        else:
            params[key] = str(value)
    return "/admin/products?" + urlencode(params)


def _admin_path_url(request: Request, path: str, **overrides: object) -> str:
    """Build an admin URL for the given path preserving query parameters."""
    params = dict(request.query_params)
    for key, value in overrides.items():
        if value is None or value == "":
            params.pop(key, None)
        else:
            params[key] = str(value)
    return path + ("?" + urlencode(params) if params else "")


def _product_list_context(request: Request, db: Session) -> dict[str, object]:
    """Build filtered, sorted, paginated product list context."""
    products = db.scalars(select(Product).options(joinedload(Product.category)).order_by(Product.name.asc())).all()
    page = int(request.query_params.get("page") or 1)
    page_size = int(request.query_params.get("page_size") or ADMIN_PAGE_SIZE_OPTIONS[0])
    sort = str(request.query_params.get("sort") or "name")
    direction = str(request.query_params.get("direction") or "asc")
    if sort not in PRODUCT_SORTS:
        sort = "name"
    if direction not in {"asc", "desc"}:
        direction = "asc"

    filters = {
        "id": str(request.query_params.get("id") or "").strip(),
        "name": str(request.query_params.get("name") or "").strip(),
        "category": str(request.query_params.get("category") or "").strip(),
        "sku": str(request.query_params.get("sku") or "").strip(),
        "barcode": str(request.query_params.get("barcode") or "").strip(),
        "unit": str(request.query_params.get("unit") or "").strip(),
        "is_active": str(request.query_params.get("is_active") or "").strip(),
    }
    rows = [
        product
        for product in products
        if (not filters["id"] or filters["id"] == str(product.id))
        and (not filters["name"] or _contains(product.name, filters["name"]))
        and (not filters["category"] or _contains(product.category.name if product.category else "", filters["category"]))
        and (not filters["sku"] or _contains(product.sku, filters["sku"]))
        and (not filters["barcode"] or _contains(product.barcode, filters["barcode"]))
        and (not filters["unit"] or _contains(product.unit, filters["unit"]))
        and (not filters["is_active"] or str(product.is_active).lower() == filters["is_active"].lower())
    ]
    sort_key = {
        "id": lambda product: product.id,
        "name": lambda product: product.name.lower(),
        "category": lambda product: (product.category.name if product.category else "").lower(),
        "sku": lambda product: (product.sku or "").lower(),
        "barcode": lambda product: (product.barcode or "").lower(),
        "unit": lambda product: product.unit.lower(),
        "is_active": lambda product: product.is_active,
    }[sort]
    rows.sort(key=sort_key, reverse=direction == "desc")
    page_rows, pagination = _admin_pagination(rows, page, page_size)
    return {
        "products": page_rows,
        "product_filters": filters,
        "product_pagination": pagination,
        "product_sort_urls": {
            name: _admin_url(
                request,
                sort=name,
                direction="desc" if name == sort and direction == "asc" else "asc",
                page=1,
            )
            for name in PRODUCT_SORTS
        },
        "product_prev_url": _admin_url(request, page=pagination["page"] - 1),
        "product_next_url": _admin_url(request, page=pagination["page"] + 1),
    }


def _product_admin_context(request: Request, db: Session) -> dict[str, object]:
    categories = db.scalars(
        select(ProductCategory).order_by(
            ProductCategory.parent_id.asc().nullsfirst(),
            ProductCategory.sort_order.asc(),
            ProductCategory.name.asc(),
        )
    ).all()
    view = str(request.query_params.get("view") or "create_product")

    category_sort = str(request.query_params.get("category_sort") or "name")
    category_direction = str(request.query_params.get("category_direction") or "asc")
    if category_sort not in CATEGORY_SORTS:
        category_sort = "name"
    if category_direction not in {"asc", "desc"}:
        category_direction = "asc"
    category_page = int(request.query_params.get("category_page") or 1)
    category_page_size = int(request.query_params.get("category_page_size") or ADMIN_PAGE_SIZE_OPTIONS[0])
    category_filters = {
        "category_id": str(request.query_params.get("category_id_filter") or "").strip(),
        "category_name": str(request.query_params.get("category_name") or "").strip(),
        "parent": str(request.query_params.get("parent") or "").strip(),
        "sort_order": str(request.query_params.get("sort_order") or "").strip(),
        "category_is_active": str(request.query_params.get("category_is_active") or "").strip(),
    }
    filtered_categories = [
        category
        for category in categories
        if (not category_filters["category_id"] or category_filters["category_id"] == str(category.id))
        and (not category_filters["category_name"] or _contains(category.name, category_filters["category_name"]))
        and (not category_filters["parent"] or _contains(category.parent.name if category.parent else "", category_filters["parent"]))
        and (not category_filters["sort_order"] or category_filters["sort_order"] == str(category.sort_order))
        and (
            not category_filters["category_is_active"]
            or str(category.is_active).lower() == category_filters["category_is_active"].lower()
        )
    ]
    category_key = {
        "id": lambda category: category.id,
        "name": lambda category: category.name.lower(),
        "parent": lambda category: (category.parent.name if category.parent else "").lower(),
        "sort_order": lambda category: category.sort_order,
        "is_active": lambda category: category.is_active,
    }[category_sort]
    filtered_categories.sort(key=category_key, reverse=category_direction == "desc")
    category_rows, category_pagination = _admin_pagination(filtered_categories, category_page, category_page_size)

    context = {
        "view": view,
        "categories": categories,
        "category_rows": category_rows,
        "category_filters": category_filters,
        "category_pagination": category_pagination,
        "category_sort": category_sort,
        "category_direction": category_direction,
        "category_sort_urls": {
            name: _admin_url(
                request,
                category_sort=name,
                category_direction="desc" if name == category_sort and category_direction == "asc" else "asc",
                category_page=1,
            )
            for name in CATEGORY_SORTS
        },
        "category_prev_url": _admin_url(request, category_page=category_pagination["page"] - 1),
        "category_next_url": _admin_url(request, category_page=category_pagination["page"] + 1),
    }
    if view == "products":
        context.update(_product_list_context(request, db))
    return context


def _user_admin_context(db: Session) -> dict[str, object]:
    users = db.scalars(select(User).options(joinedload(User.role)).order_by(User.id.asc())).all()
    roles = db.scalars(select(Role).order_by(Role.id.asc())).all()
    return {"users": users, "roles": roles}


def _cell_admin_context(request: Request, db: Session) -> dict[str, object]:
    controllers = db.scalars(select(Controller).order_by(Controller.id.asc())).all()
    all_cells = db.scalars(select(Cell).options(joinedload(Cell.controller)).order_by(Cell.number.asc())).all()
    page = int(request.query_params.get("page") or 1)
    page_size = int(request.query_params.get("page_size") or ADMIN_PAGE_SIZE_OPTIONS[0])
    cells, pagination = _admin_pagination(all_cells, page, page_size)
    return {
        "controllers": controllers,
        "cells": cells,
        "cell_statuses": list(CellStatus),
        "pagination": pagination,
        "cell_prev_url": _admin_path_url(request, "/admin/cells", page=pagination["page"] - 1),
        "cell_next_url": _admin_path_url(request, "/admin/cells", page=pagination["page"] + 1),
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


def _logs_admin_context(request: Request, db: Session) -> dict[str, object]:
    view = str(request.query_params.get("view") or "movements")
    if view not in {"movements", "access", "sessions"}:
        view = "movements"
    movements = db.scalars(
        select(StockMovement)
        .options(joinedload(StockMovement.product))
        .order_by(StockMovement.created_at.desc())
        .limit(50)
    ).all()
    events = db.scalars(
        select(AccessEvent)
        .options(joinedload(AccessEvent.user))
        .order_by(AccessEvent.created_at.desc())
        .limit(50)
    ).all()
    sessions = db.scalars(select(CellSession).order_by(CellSession.created_at.desc()).limit(50)).all()
    return {
        "view": view,
        "movements": movements,
        "events": events,
        "sessions": sessions,
        "active_session": SessionService.get_active_session(db),
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
        _product_admin_context(request, db),
    )


@router.get("/cells", response_class=HTMLResponse)
def admin_cells(request: Request, db: Session = Depends(get_db)) -> HTMLResponse:
    """Show cell management in a separate admin tab."""
    return templates.TemplateResponse(
        request,
        "admin/cells.html",
        _cell_admin_context(request, db),
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
        _logs_admin_context(request, db),
    )


@router.post("/users", response_class=HTMLResponse)
async def create_user(request: Request, db: Session = Depends(get_db)) -> RedirectResponse:
    """Create a user from the admin MVP form."""
    form = await request.form()
    db.add(
        User(
            last_name=str(form["last_name"]).strip(),
            first_name=str(form["first_name"]).strip(),
            middle_name=str(form.get("middle_name") or "").strip() or None,
            department=str(form.get("department") or "").strip() or None,
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
    user.last_name = str(form["last_name"]).strip()
    user.first_name = str(form["first_name"]).strip()
    user.middle_name = str(form.get("middle_name") or "").strip() or None
    user.department = str(form.get("department") or "").strip() or None
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
    return RedirectResponse(url="/admin/products?view=products", status_code=303)


@router.post("/products/{product_id}", response_class=HTMLResponse)
async def update_product(request: Request, product_id: int, db: Session = Depends(get_db)) -> RedirectResponse:
    """Update a product from the admin MVP form."""
    product = db.get(Product, product_id)
    if product is None:
        raise NotFoundError("Product not found")
    form = await request.form()
    product.name = str(form["name"]).strip()
    product.sku = str(form.get("sku") or "").strip() or None
    product.barcode = str(form.get("barcode") or "").strip() or None
    product.unit = str(form.get("unit") or "pcs").strip()
    product.external_id = str(form.get("external_id") or "").strip() or None
    product.category_id = int(form["category_id"]) if form.get("category_id") else None
    product.is_active = str(form.get("is_active", "off")) == "on"
    db.commit()
    return RedirectResponse(url="/admin/products?view=products", status_code=303)


@router.post("/products/{product_id}/toggle-active", response_class=HTMLResponse)
def toggle_product_active(product_id: int, db: Session = Depends(get_db)) -> RedirectResponse:
    """Activate or deactivate a product from the admin product list."""
    product = db.get(Product, product_id)
    if product is None:
        raise NotFoundError("Product not found")
    product.is_active = not product.is_active
    db.commit()
    return RedirectResponse(url="/admin/products?view=products", status_code=303)


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
    return RedirectResponse(url="/admin/products?view=categories", status_code=303)


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
    return RedirectResponse(url="/admin/products?view=categories", status_code=303)


@router.post("/categories/{category_id}/toggle-active", response_class=HTMLResponse)
def toggle_category_active(category_id: int, db: Session = Depends(get_db)) -> RedirectResponse:
    """Activate or deactivate a product category."""
    category = db.get(ProductCategory, category_id)
    if category is None:
        raise NotFoundError("Product category not found")
    category.is_active = not category.is_active
    db.commit()
    return RedirectResponse(url="/admin/products?view=categories", status_code=303)


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
    return RedirectResponse(url="/admin/cells", status_code=303)


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
    return RedirectResponse(url="/admin/cells", status_code=303)


@router.post("/cells/{cell_id}/toggle-block", response_class=HTMLResponse)
def toggle_cell_block(cell_id: int, db: Session = Depends(get_db)) -> RedirectResponse:
    """Block or unblock a storage cell from the admin MVP panel."""
    cell = db.get(Cell, cell_id)
    if cell is None:
        raise NotFoundError("Cell not found")
    cell.status = CellStatus.ACTIVE if cell.status == CellStatus.BLOCKED else CellStatus.BLOCKED
    db.commit()
    return RedirectResponse(url="/admin/cells", status_code=303)


@router.post("/stock", response_class=HTMLResponse)
async def create_stock_item(request: Request, db: Session = Depends(get_db)) -> RedirectResponse:
    """Create initial stock row from the admin MVP form."""
    form = await request.form()
    product_id = int(form["product_id"])
    cell_id = int(form["cell_id"])
    quantity = Decimal(str(form["quantity"]))
    StockService.set_current_quantity(
        db,
        product_id=product_id,
        cell_id=cell_id,
        quantity=quantity,
    )
    db.commit()
    return RedirectResponse(url="/admin/stock#stock", status_code=303)


@router.post("/sessions/{session_id}/emergency-cancel", response_class=HTMLResponse)
async def emergency_cancel(request: Request, session_id: int, db: Session = Depends(get_db)) -> RedirectResponse:
    """Emergency-cancel an active session from admin panel."""
    form = await request.form()
    reason = str(form.get("reason") or "Emergency admin cancellation")
    SessionService.cancel(db, session_id=session_id, reason=reason)
    return RedirectResponse(url="/admin/logs?view=sessions", status_code=303)
