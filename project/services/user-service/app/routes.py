import uuid
from datetime import datetime
from fastapi import APIRouter, HTTPException, Depends, status
from app.models import UserRegister, UserLogin, UserResponse, TokenResponse
from app.auth import hash_password, verify_password, create_access_token, get_current_user
from app.database import get_db
from app.config import HARDCODED_OTP

router = APIRouter()


@router.post("/register", response_model=UserResponse, status_code=201)
async def register(user: UserRegister):
    db = get_db()
    existing = await db.users.find_one({"email": user.email})
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    user_id = str(uuid.uuid4())
    now = datetime.utcnow()
    doc = {
        "user_id": user_id,
        "name": user.name,
        "email": user.email,
        "hashed_password": hash_password(user.password),
        "created_at": now,
    }
    await db.users.insert_one(doc)
    return UserResponse(user_id=user_id, name=user.name, email=user.email, created_at=now)


@router.post("/login", response_model=TokenResponse)
async def login(data: UserLogin):
    if data.otp != HARDCODED_OTP:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    db = get_db()
    user = await db.users.find_one({"email": data.email})
    if not user or not verify_password(data.password, user["hashed_password"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_access_token({"sub": user["user_id"], "email": user["email"]})
    return TokenResponse(
        access_token=token,
        user_id=user["user_id"],
        name=user["name"],
    )


@router.get("/profile", response_model=UserResponse)
async def profile(current_user: dict = Depends(get_current_user)):
    db = get_db()
    user = await db.users.find_one({"user_id": current_user["sub"]})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return UserResponse(
        user_id=user["user_id"],
        name=user["name"],
        email=user["email"],
        created_at=user["created_at"],
    )
