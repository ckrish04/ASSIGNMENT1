from pydantic import BaseModel
from typing import Optional


class Product(BaseModel):
    product_id: str
    name: str
    description: str
    price: float
    category: str
    image_url: str
    availability: bool = True


class Category(BaseModel):
    name: str
    image_url: str
