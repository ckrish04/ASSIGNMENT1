from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class CartAddRequest(BaseModel):
    product_id: str
    quantity: int = 1


class CartRemoveRequest(BaseModel):
    product_id: str


class CartItem(BaseModel):
    product_id: str
    quantity: int


class CartResponse(BaseModel):
    user_id: str
    items: List[CartItem]


class OrderItem(BaseModel):
    product_id: str
    quantity: int
    price: float


class OrderResponse(BaseModel):
    order_id: str
    reference_id: str
    user_id: str
    items: List[OrderItem]
    order_total: float
    order_timestamp: datetime
    status: str = "PLACED"
