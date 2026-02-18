"""Seed script to populate products collection with sample data."""
import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import os

MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
DB_NAME = os.getenv("DB_NAME", "product_db")

SAMPLE_PRODUCTS = [
    {
        "product_id": "p001",
        "name": "Fresh Whole Milk (1L)",
        "description": "Farm-fresh pasteurized whole milk",
        "price": 65.0,
        "category": "Dairy",
        "image_url": "https://via.placeholder.com/200?text=Milk",
        "availability": True,
    },
    {
        "product_id": "p002",
        "name": "Brown Eggs (12 pack)",
        "description": "Free-range brown eggs",
        "price": 89.0,
        "category": "Dairy",
        "image_url": "https://via.placeholder.com/200?text=Eggs",
        "availability": True,
    },
    {
        "product_id": "p003",
        "name": "Organic Bananas (1 dozen)",
        "description": "Fresh organic bananas",
        "price": 49.0,
        "category": "Fruits",
        "image_url": "https://via.placeholder.com/200?text=Bananas",
        "availability": True,
    },
    {
        "product_id": "p004",
        "name": "Red Apples (1 kg)",
        "description": "Crispy red delicious apples",
        "price": 120.0,
        "category": "Fruits",
        "image_url": "https://via.placeholder.com/200?text=Apples",
        "availability": True,
    },
    {
        "product_id": "p005",
        "name": "Spinach (250g)",
        "description": "Fresh baby spinach leaves",
        "price": 35.0,
        "category": "Vegetables",
        "image_url": "https://via.placeholder.com/200?text=Spinach",
        "availability": True,
    },
    {
        "product_id": "p006",
        "name": "Tomatoes (500g)",
        "description": "Vine-ripened tomatoes",
        "price": 30.0,
        "category": "Vegetables",
        "image_url": "https://via.placeholder.com/200?text=Tomatoes",
        "availability": True,
    },
    {
        "product_id": "p007",
        "name": "Whole Wheat Bread",
        "description": "Freshly baked whole wheat bread",
        "price": 45.0,
        "category": "Bakery",
        "image_url": "https://via.placeholder.com/200?text=Bread",
        "availability": True,
    },
    {
        "product_id": "p008",
        "name": "Butter (200g)",
        "description": "Salted table butter",
        "price": 55.0,
        "category": "Dairy",
        "image_url": "https://via.placeholder.com/200?text=Butter",
        "availability": True,
    },
    {
        "product_id": "p009",
        "name": "Chicken Breast (500g)",
        "description": "Boneless skinless chicken breast",
        "price": 180.0,
        "category": "Meat",
        "image_url": "https://via.placeholder.com/200?text=Chicken",
        "availability": True,
    },
    {
        "product_id": "p010",
        "name": "Basmati Rice (1 kg)",
        "description": "Premium aged basmati rice",
        "price": 95.0,
        "category": "Staples",
        "image_url": "https://via.placeholder.com/200?text=Rice",
        "availability": True,
    },
    {
        "product_id": "p011",
        "name": "Coca-Cola (500ml)",
        "description": "Chilled Coca-Cola bottle",
        "price": 40.0,
        "category": "Beverages",
        "image_url": "https://via.placeholder.com/200?text=Coke",
        "availability": True,
    },
    {
        "product_id": "p012",
        "name": "Potato Chips (150g)",
        "description": "Classic salted potato chips",
        "price": 30.0,
        "category": "Snacks",
        "image_url": "https://via.placeholder.com/200?text=Chips",
        "availability": True,
    },
]


async def seed():
    client = AsyncIOMotorClient(MONGO_URI)
    db = client[DB_NAME]
    count = await db.products.count_documents({})
    if count == 0:
        await db.products.insert_many(SAMPLE_PRODUCTS)
        print(f"Seeded {len(SAMPLE_PRODUCTS)} products.")
    else:
        print(f"Database already has {count} products. Skipping seed.")
    client.close()


if __name__ == "__main__":
    asyncio.run(seed())
