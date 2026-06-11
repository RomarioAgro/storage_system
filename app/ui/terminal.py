from decimal import Decimal

from fastapi import APIRouter, Depends, Request
from fastapi.responses import HTMLResponse, RedirectResponse, Response
from sqlalchemy import func, select
from sqlalchemy.orm import Session, joinedload

from app.api.deps import get_lock_controller
from app.core.database import get_db
from app.hardware.lock_controller import LockController
from app.models.cell import Cell
from app.models.product import Product
from app.models.product_category import ProductCategory
from app.models.stock_item import StockItem
from app.models.user import User
from app.services.auth_service import AuthService
from app.services.errors import AppError
from app.services.operation_service import OperationService
from app.services.permission_service import PermissionService
from app.services.session_service import SessionService
from app.ui.templates import templates

router = APIRouter(prefix="/terminal", tags=["terminal-ui"], include_in_schema=False)


def _active_context(db: Session) -> dict[str, object] | None:
    """Build template context for an unfinished active session.

    Args:
        db: SQLAlchemy session.

    Returns:
        Context dictionary when an active session exists, otherwise None.
    """
    session = SessionService.get_active_session(db)
    if session is None:
        return None
    return {"active_session": session}


def _render_blocker(request: Request, db: Session) -> HTMLResponse | None:
    """Render active-session blocking screen when needed.

    Args:
        request: Current HTTP request.
        db: SQLAlchemy session.

    Returns:
        HTML response if the UI must be blocked, otherwise None.
    """
    context = _active_context(db)
    if context is None:
        return None
    return templates.TemplateResponse(request, "terminal/active_session.html", context)


def _get_user(db: Session, user_id: int) -> User:
    """Load an active UI user by id.

    Args:
        db: SQLAlchemy session.
        user_id: User identifier from the current MVP UI form.

    Returns:
        Active user with role loaded.

    Raises:
        AppError: If the user is not active or not found.
    """
    return OperationService._get_user(db, user_id)


def _current_user(request: Request, db: Session) -> User:
    """Return the terminal user stored in the local UI session.

    Args:
        request: Current HTTP request.
        db: SQLAlchemy session.

    Returns:
        Active user with role loaded.

    Raises:
        AppError: If there is no authenticated terminal UI session.
    """
    user_id = request.session.get("terminal_user_id")
    if user_id is None:
        raise AppError("Terminal UI session is not authenticated")
    return _get_user(db, int(user_id))


def _require_user(request: Request, db: Session) -> User | RedirectResponse:
    """Return current terminal user or redirect to RFID prompt."""
    try:
        return _current_user(request, db)
    except AppError:
        return RedirectResponse(url="/terminal", status_code=303)


def _product_stock(db: Session, product_id: int) -> tuple[Decimal, list[StockItem]]:
    """Return total stock and per-cell rows for a product."""
    total = db.scalar(
        select(func.coalesce(func.sum(StockItem.quantity), Decimal("0.000"))).where(
            StockItem.product_id == product_id
        )
    )
    rows = db.scalars(
        select(StockItem)
        .options(joinedload(StockItem.cell), joinedload(StockItem.product))
        .where(StockItem.product_id == product_id, StockItem.quantity > 0)
        .order_by(StockItem.cell_id.asc())
    ).all()
    return total or Decimal("0.000"), list(rows)


def _can_manage_products(user: User) -> bool:
    """Return whether a user can create or edit products.

    Args:
        user: Authenticated terminal user.

    Returns:
        True when the user's role includes product management permission.
    """
    try:
        PermissionService.require(user, "manage_products")
    except AppError:
        return False
    return True


@router.get("", response_class=HTMLResponse)
def terminal_home(request: Request, db: Session = Depends(get_db)) -> HTMLResponse:
    """Show RFID prompt or active-session blocking screen."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    return templates.TemplateResponse(request, "terminal/rfid.html")


@router.post("/rfid", response_class=HTMLResponse)
async def terminal_rfid(request: Request, db: Session = Depends(get_db)) -> HTMLResponse:
    """Authenticate RFID card and show the terminal menu."""
    form = await request.form()
    rfid_uid = str(form.get("rfid_uid", "")).strip()
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    try:
        user = AuthService.authenticate_rfid(
            db,
            rfid_uid,
            client_ip=request.client.host if request.client else None,
        )
    except AppError:
        return templates.TemplateResponse(
            request,
            "terminal/rfid.html",
            {"error": "Ключ не найден или заблокирован"},
            status_code=403,
        )
    request.session["terminal_user_id"] = user.id
    return templates.TemplateResponse(
        request,
        "terminal/menu.html",
        {"user": user, "can_manage_products": _can_manage_products(user)},
    )


@router.get("/menu", response_class=HTMLResponse)
def terminal_menu(request: Request, db: Session = Depends(get_db)) -> Response:
    """Show the terminal main menu for an authenticated MVP user."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    return templates.TemplateResponse(
        request,
        "terminal/menu.html",
        {"user": user, "can_manage_products": _can_manage_products(user)},
    )


@router.get("/products/new", response_class=HTMLResponse)
def new_product_form(request: Request, db: Session = Depends(get_db)) -> Response:
    """Show product creation form for managers and admins."""
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    PermissionService.require(user, "manage_products")
    categories = db.scalars(
        select(ProductCategory)
        .where(ProductCategory.is_active.is_(True))
        .order_by(
            ProductCategory.parent_id.asc().nullsfirst(),
            ProductCategory.sort_order.asc(),
            ProductCategory.name.asc(),
        )
    ).all()
    return templates.TemplateResponse(
        request,
        "terminal/new_product.html",
        {"user": user, "categories": categories},
    )


@router.post("/products", response_class=HTMLResponse)
async def create_product(request: Request, db: Session = Depends(get_db)) -> Response:
    """Create a product from terminal UI when the role allows it."""
    user = _current_user(request, db)
    PermissionService.require(user, "manage_products")
    form = await request.form()
    category_id = int(form["category_id"]) if form.get("category_id") else None
    if category_id is not None and db.get(ProductCategory, category_id) is None:
        from app.services.errors import NotFoundError

        raise NotFoundError("Product category not found")
    product = Product(
        name=str(form["name"]).strip(),
        sku=str(form.get("sku") or "").strip() or None,
        barcode=str(form.get("barcode") or "").strip() or None,
        unit=str(form.get("unit") or "pcs").strip() or "pcs",
        external_id=str(form.get("external_id") or "").strip() or None,
        category_id=category_id,
    )
    db.add(product)
    db.commit()
    db.refresh(product)
    return RedirectResponse(url=f"/terminal/products/{product.id}", status_code=303)


@router.get("/search", response_class=HTMLResponse)
def search_products(
    request: Request,
    query: str = "",
    db: Session = Depends(get_db),
) -> Response:
    """Search products from terminal UI."""
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    products: list[Product] = []
    q = query.strip()
    if q:
        statement = select(Product).where(Product.is_active.is_(True))
        products = list(db.scalars(statement.where(Product.barcode == q)).all())
        if not products:
            products = list(db.scalars(statement.where(Product.sku == q)).all())
        if not products:
            products = list(
                db.scalars(statement.where(Product.name.ilike(f"%{q}%")).order_by(Product.name.asc())).all()
            )
    return templates.TemplateResponse(
        request,
        "terminal/search.html",
        {"user": user, "query": query, "products": products},
    )


@router.get("/products/{product_id}", response_class=HTMLResponse)
def product_card(
    request: Request,
    product_id: int,
    db: Session = Depends(get_db),
) -> Response:
    """Show product card with stock and operation forms."""
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    product = db.get(Product, product_id)
    cells = db.scalars(select(Cell).order_by(Cell.number.asc())).all()
    total, stock_rows = _product_stock(db, product_id)
    return templates.TemplateResponse(
        request,
        "terminal/product.html",
        {
            "user": user,
            "product": product,
            "cells": cells,
            "stock_rows": stock_rows,
            "total": total,
        },
    )


@router.post("/fill/start", response_class=HTMLResponse)
async def start_fill(
    request: Request,
    db: Session = Depends(get_db),
    lock_controller: LockController = Depends(get_lock_controller),
) -> HTMLResponse:
    """Start a fill operation from terminal UI."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    form = await request.form()
    user = _current_user(request, db)
    session = OperationService.start_fill(
        db=db,
        lock_controller=lock_controller,
        user_id=user.id,
        product_id=int(form["product_id"]),
        cell_id=int(form["cell_id"]),
        quantity=Decimal(str(form["quantity"])),
        comment=str(form.get("comment") or ""),
    )
    return templates.TemplateResponse(
        request,
        "terminal/opened.html",
        {"session": session, "next_action": "fill"},
    )


@router.post("/take/start", response_class=HTMLResponse)
async def start_take(
    request: Request,
    db: Session = Depends(get_db),
    lock_controller: LockController = Depends(get_lock_controller),
) -> HTMLResponse:
    """Start a take operation from terminal UI."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    form = await request.form()
    user = _current_user(request, db)
    session = OperationService.start_take(
        db=db,
        lock_controller=lock_controller,
        user_id=user.id,
        product_id=int(form["product_id"]),
        cell_id=int(form["cell_id"]),
        quantity=Decimal(str(form["quantity"])),
        comment=str(form.get("comment") or ""),
    )
    return templates.TemplateResponse(
        request,
        "terminal/opened.html",
        {"session": session, "next_action": "take"},
    )


@router.post("/inventory/start", response_class=HTMLResponse)
async def start_inventory(
    request: Request,
    db: Session = Depends(get_db),
    lock_controller: LockController = Depends(get_lock_controller),
) -> HTMLResponse:
    """Start an inventory operation from terminal UI."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    form = await request.form()
    user = _current_user(request, db)
    session = OperationService.start_inventory(
        db=db,
        lock_controller=lock_controller,
        user_id=user.id,
        product_id=int(form["product_id"]),
        cell_id=int(form["cell_id"]),
        actual_quantity=Decimal(str(form["actual_quantity"])),
        comment=str(form.get("comment") or ""),
    )
    return templates.TemplateResponse(
        request,
        "terminal/opened.html",
        {"session": session, "next_action": "inventory"},
    )


@router.get("/cell-contents", response_class=HTMLResponse)
def cell_contents_form(
    request: Request,
    cell_id: int | None = None,
    db: Session = Depends(get_db),
) -> Response:
    """Show cell contents lookup screen."""
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    cells = db.scalars(select(Cell).order_by(Cell.number.asc())).all()
    rows = []
    selected_cell = None
    if cell_id:
        selected_cell = db.get(Cell, cell_id)
        rows = db.scalars(
            select(StockItem)
            .options(joinedload(StockItem.product))
            .where(StockItem.cell_id == cell_id, StockItem.quantity > 0)
            .order_by(StockItem.product_id.asc())
        ).all()
    return templates.TemplateResponse(
        request,
        "terminal/cell_contents.html",
        {
            "user": user,
            "cells": cells,
            "selected_cell": selected_cell,
            "rows": rows,
        },
    )


@router.get("/open-only", response_class=HTMLResponse)
def open_only_form(request: Request, db: Session = Depends(get_db)) -> Response:
    """Show service opening form."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    user = _require_user(request, db)
    if isinstance(user, RedirectResponse):
        return user
    cells = db.scalars(select(Cell).order_by(Cell.number.asc())).all()
    return templates.TemplateResponse(
        request,
        "terminal/open_only.html",
        {"user": user, "cells": cells},
    )


@router.post("/open-only/start", response_class=HTMLResponse)
async def start_open_only(
    request: Request,
    db: Session = Depends(get_db),
    lock_controller: LockController = Depends(get_lock_controller),
) -> HTMLResponse:
    """Start open-only operation from terminal UI."""
    blocker = _render_blocker(request, db)
    if blocker:
        return blocker
    form = await request.form()
    user = _current_user(request, db)
    session = OperationService.start_open_only(
        db=db,
        lock_controller=lock_controller,
        user_id=user.id,
        cell_id=int(form["cell_id"]),
        comment=str(form.get("comment") or ""),
    )
    return templates.TemplateResponse(
        request,
        "terminal/opened.html",
        {"session": session, "next_action": "open_only"},
    )


@router.post("/sessions/{session_id}/confirm-close", response_class=HTMLResponse)
async def confirm_close(request: Request, session_id: int, db: Session = Depends(get_db)) -> HTMLResponse:
    """Confirm that the physical cell was closed."""
    form = await request.form()
    next_action = str(form.get("next_action") or "")
    session = SessionService.confirm_close(db, session_id=session_id)
    return templates.TemplateResponse(
        request,
        "terminal/confirm_operation.html",
        {"session": session, "next_action": next_action},
    )


@router.post("/fill/{session_id}/confirm", response_class=HTMLResponse)
async def confirm_fill(request: Request, session_id: int, db: Session = Depends(get_db)) -> HTMLResponse:
    """Confirm fill operation and apply stock change."""
    form = await request.form()
    session = OperationService.confirm_fill(db, session_id=session_id, comment=str(form.get("comment") or ""))
    return templates.TemplateResponse(request, "terminal/done.html", {"session": session})


@router.post("/take/{session_id}/confirm", response_class=HTMLResponse)
async def confirm_take(request: Request, session_id: int, db: Session = Depends(get_db)) -> HTMLResponse:
    """Confirm take operation and apply stock change."""
    form = await request.form()
    session = OperationService.confirm_take(db, session_id=session_id, comment=str(form.get("comment") or ""))
    return templates.TemplateResponse(request, "terminal/done.html", {"session": session})


@router.post("/inventory/{session_id}/confirm", response_class=HTMLResponse)
async def confirm_inventory(request: Request, session_id: int, db: Session = Depends(get_db)) -> HTMLResponse:
    """Confirm inventory operation and apply stock count."""
    form = await request.form()
    session = OperationService.confirm_inventory(
        db,
        session_id=session_id,
        comment=str(form.get("comment") or ""),
    )
    return templates.TemplateResponse(request, "terminal/done.html", {"session": session})


@router.post("/open-only/{session_id}/complete", response_class=HTMLResponse)
def complete_open_only(request: Request, session_id: int, db: Session = Depends(get_db)) -> HTMLResponse:
    """Complete open-only session after close confirmation."""
    session = OperationService.complete_open_only(db, session_id=session_id)
    return templates.TemplateResponse(request, "terminal/done.html", {"session": session})


@router.post("/sessions/{session_id}/cancel", response_class=HTMLResponse)
async def cancel_session(request: Request, session_id: int, db: Session = Depends(get_db)) -> HTMLResponse:
    """Cancel active session without changing stock."""
    form = await request.form()
    session = SessionService.cancel(db, session_id=session_id, reason=str(form.get("reason") or "UI cancel"))
    return templates.TemplateResponse(request, "terminal/done.html", {"session": session})


@router.get("/logout", response_class=HTMLResponse)
def logout(request: Request) -> RedirectResponse:
    """Return to RFID prompt."""
    request.session.clear()
    return RedirectResponse(url="/terminal", status_code=303)
