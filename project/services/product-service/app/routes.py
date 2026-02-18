from fastapi import APIRouter, HTTPException
from typing import List, Optional
from app.models import Product, Category
from app.database import get_db

router = APIRouter()


@router.get("/products", response_model=List[Product])
async def list_products(category: Optional[str] = None):
    db = get_db()
    query = {}
    if category:
        query["category"] = category
    products = await db.products.find(query).to_list(100)
    return [
        Product(
            product_id=p["product_id"],
            name=p["name"],
            description=p["description"],
            price=p["price"],
            category=p["category"],
            image_url=p["image_url"],
            availability=p.get("availability", True),
        )
        for p in products
    ]


@router.get("/products/{product_id}", response_model=Product)
async def get_product(product_id: str):
    db = get_db()
    p = await db.products.find_one({"product_id": product_id})
    if not p:
        raise HTTPException(status_code=404, detail="Product not found")
    return Product(
        product_id=p["product_id"],
        name=p["name"],
        description=p["description"],
        price=p["price"],
        category=p["category"],
        image_url=p["image_url"],
        availability=p.get("availability", True),
    )


@router.get("/categories", response_model=List[Category])
async def list_categories():
    db = get_db()
    pipeline = [
        {"$group": {"_id": "$category", "image_url": {"$first": "$image_url"}}},
        {"$sort": {"_id": 1}},
    ]
    results = await db.products.aggregate(pipeline).to_list(50)
    return [Category(name=r["_id"], image_url=r["image_url"]) for r in results]
