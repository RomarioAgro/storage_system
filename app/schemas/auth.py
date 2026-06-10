from pydantic import BaseModel


class RfidAuthRequest(BaseModel):
    rfid_uid: str


class RfidAuthResponse(BaseModel):
    user_id: int
    name: str
    role: str
