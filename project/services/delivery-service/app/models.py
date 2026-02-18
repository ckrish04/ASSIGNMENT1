from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class StatusUpdate(BaseModel):
    status: str


class DeliveryStatus(BaseModel):
    order_id: str
    current_status: str
    last_updated: datetime
