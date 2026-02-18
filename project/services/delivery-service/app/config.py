import os

MONGO_URI = os.getenv("MONGO_URI", "mongodb://mongo:27017")
DB_NAME = os.getenv("DB_NAME", "delivery_db")
JWT_SECRET = os.getenv("JWT_SECRET", "super-secret-key-change-in-prod")
JWT_ALGORITHM = "HS256"

VALID_STATUSES = ["PLACED", "PACKED", "OUT_FOR_DELIVERY", "DELIVERED"]
STATUS_FLOW = {
    "PLACED": "PACKED",
    "PACKED": "OUT_FOR_DELIVERY",
    "OUT_FOR_DELIVERY": "DELIVERED",
}
