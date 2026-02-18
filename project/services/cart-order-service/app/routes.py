import uuid
import httpx
from datetime import datetime
from fastapi import APIRouter, HTTPException, Depends
from typing import List
from app.models import (
    CartAddRequest,
    CartRemoveRequest,
    CartResponse,
    CartItem,
    OrderResponse,
    OrderItem,
)
from app.auth import get_current_user
from app.database import get_db
from app.config import PRODUCT_SERVICE_URL, DELIVERY_SERVICE_URL

router = APIRouter()


# ─── CART ───────────────────────────────────────────────


@router.post("/cart/add")
async def add_to_cart(req: CartAddRequest, user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = user["sub"]
    existing = await db.cart.find_one(
        {"user_id": user_id, "product_id": req.product_id}
    )
    if existing:
        await db.cart.update_one(
            {"_id": existing["_id"]},
            {"$inc": {"quantity": req.quantity}},
        )
    else:
        await db.cart.insert_one(
            {
                "user_id": user_id,
                "product_id": req.product_id,
                "quantity": req.quantity,
            }
        )
    return {"message": "Item added to cart"}


@router.post("/cart/remove")
async def remove_from_cart(
    req: CartRemoveRequest, user: dict = Depends(get_current_user)
):
    db = get_db()
    user_id = user["sub"]
    result = await db.cart.delete_one(
        {"user_id": user_id, "product_id": req.product_id}
    )
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Item not in cart")
    return {"message": "Item removed from cart"}


@router.get("/cart", response_model=CartResponse)
async def get_cart(user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = user["sub"]
    items = await db.cart.find({"user_id": user_id}).to_list(100)
    return CartResponse(
        user_id=user_id,
        items=[CartItem(product_id=i["product_id"], quantity=i["quantity"]) for i in items],
    )


# ─── ORDERS ─────────────────────────────────────────────


@router.post("/order/create", response_model=OrderResponse)
async def create_order(user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = user["sub"]

    cart_items = await db.cart.find({"user_id": user_id}).to_list(100)
    if not cart_items:
        raise HTTPException(status_code=400, detail="Cart is empty")

    # Fetch product prices from product service
    order_items = []
    total = 0.0
    async with httpx.AsyncClient() as client:
        for item in cart_items:
            resp = await client.get(
                f"{PRODUCT_SERVICE_URL}/products/{item['product_id']}"
            )
            if resp.status_code != 200:
                raise HTTPException(
                    status_code=400,
                    detail=f"Product {item['product_id']} not found",
                )
            product = resp.json()
            line_total = product["price"] * item["quantity"]
            total += line_total
            order_items.append(
                {
                    "product_id": item["product_id"],
                    "quantity": item["quantity"],
                    "price": product["price"],
                }
            )

    order_id = str(uuid.uuid4())
    reference_id = f"ORD-{uuid.uuid4().hex[:8].upper()}"
    now = datetime.utcnow()

    order_doc = {
        "order_id": order_id,
        "reference_id": reference_id,
        "user_id": user_id,
        "items": order_items,
        "order_total": round(total, 2),
        "order_timestamp": now,
        "status": "PLACED",
    }
    await db.orders.insert_one(order_doc)

    # Clear cart
    await db.cart.delete_many({"user_id": user_id})

    # Notify delivery service (fire and forget, trusted internal)
    try:
        async with httpx.AsyncClient() as client:
            await client.post(
                f"{DELIVERY_SERVICE_URL}/order/{order_id}/update-status",
                json={"status": "PLACED"},
            )
    except Exception:
        pass  # Delivery service might not be up yet

    return OrderResponse(
        order_id=order_id,
        reference_id=reference_id,
        user_id=user_id,
        items=[
            OrderItem(
                product_id=i["product_id"],
                quantity=i["quantity"],
                price=i["price"],
            )
            for i in order_items
        ],
        order_total=round(total, 2),
        order_timestamp=now,
    )


@router.get("/orders", response_model=List[OrderResponse])
async def get_orders(user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = user["sub"]
    orders = await db.orders.find({"user_id": user_id}).sort("order_timestamp", -1).to_list(50)
    return [
        OrderResponse(
            order_id=o["order_id"],
            reference_id=o["reference_id"],
            user_id=o["user_id"],
            items=[
                OrderItem(
                    product_id=i["product_id"],
                    quantity=i["quantity"],
                    price=i["price"],
                )
                for i in o["items"]
            ],
            order_total=o["order_total"],
            order_timestamp=o["order_timestamp"],
            status=o.get("status", "PLACED"),
        )
        for o in orders
    ]
