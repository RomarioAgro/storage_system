from fastapi import APIRouter

from app.api.routes import auth, cells, health, operations, products, sessions

api_router = APIRouter()
api_router.include_router(health.router, tags=["health"])
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(products.router, prefix="/products", tags=["products"])
api_router.include_router(cells.router, prefix="/cells", tags=["cells"])
api_router.include_router(operations.router, prefix="/operations", tags=["operations"])
api_router.include_router(sessions.router, prefix="/sessions", tags=["sessions"])
