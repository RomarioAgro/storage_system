from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    app_name: str = "Storage System MVP"
    database_url: str = "sqlite:///./storage_system.db"
    lock_controller: str = "mock"
    lock_pulse_seconds: float = 1.0
    auto_create_tables: bool = True
    ui_session_secret: str = "local-dev-session-secret"


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
