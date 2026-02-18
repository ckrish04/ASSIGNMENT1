import os

MONGO_URI = os.getenv("MONGO_URI", "mongodb://mongo:27017")
DB_NAME = os.getenv("DB_NAME", "user_db")
JWT_SECRET = os.getenv("JWT_SECRET", "super-secret-key-change-in-prod")
JWT_ALGORITHM = "HS256"
JWT_EXPIRATION_MINUTES = 60 * 24  # 24 hours
HARDCODED_OTP = "1234"
