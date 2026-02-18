from datetime import datetime
from fastapi import APIRouter, HTTPException, Depends
from app.models import StatusUpdate, DeliveryStatus
from app.auth import get_current_user
from app.database import get_db
from app.config import VALID_STATUSES

router = APIRouter()


@router.get("/order/{order_id}/status", response_model=DeliveryStatus)
async def get_status(order_id: str, user: dict = Depends(get_current_user)):
    db = get_db()
    record = await db.deliveries.find_one({"order_id": order_id})
    if not record:
        raise HTTPException(status_code=404, detail="Delivery record not found")
    return DeliveryStatus(
        order_id=record["order_id"],
        current_status=record["current_status"],
        last_updated=record["last_updated"],
    )


@router.post("/order/{order_id}/update-status", response_model=DeliveryStatus)
async def update_status(order_id: str, req: StatusUpdate):
    """Internal endpoint — no JWT required (trusted service communication)."""
    if req.status not in VALID_STATUSES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid status. Must be one of: {VALID_STATUSES}",
        )

    db = get_db()
    now = datetime.utcnow()

    existing = await db.deliveries.find_one({"order_id": order_id})
    if existing:
        await db.deliveries.update_one(
            {"order_id": order_id},
            {"$set": {"current_status": req.status, "last_updated": now}},
        )
    else:
        await db.deliveries.insert_one(
            {
                "order_id": order_id,
                "current_status": req.status,
                "last_updated": now,
            }
        )

    return DeliveryStatus(
        order_id=order_id, current_status=req.status, last_updated=now
    )
