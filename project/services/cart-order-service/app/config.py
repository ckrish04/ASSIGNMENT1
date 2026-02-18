import os

MONGO_URI = os.getenv("MONGO_URI", "mongodb://mongo:27017")
DB_NAME = os.getenv("DB_NAME", "cart_order_db")
JWT_SECRET = os.getenv("JWT_SECRET", "super-secret-key-change-in-prod")
JWT_ALGORITHM = "HS256"
PRODUCT_SERVICE_URL = os.getenv("PRODUCT_SERVICE_URL", "http://product-service:8002")
DELIVERY_SERVICE_URL = os.getenv("DELIVERY_SERVICE_URL", "http://delivery-service:8004")
