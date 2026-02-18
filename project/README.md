# QuickCommerce — B2C Quick Commerce Application

A Blinkit-style quick-commerce platform built with FastAPI microservices, MongoDB, Docker, Kubernetes, and a Flutter mobile frontend.

---

## Architecture Overview

```
┌──────────────┐     ┌──────────────────┐     ┌───────────────────┐     ┌──────────────────┐
│ User Service │     │ Product Catalog  │     │ Cart & Order      │     │ Delivery Status  │
│   :8001      │     │   Service :8002  │     │   Service :8003   │     │   Service :8004  │
└──────┬───────┘     └────────┬─────────┘     └────────┬──────────┘     └────────┬─────────┘
       │                      │                        │                         │
       └──────────────────────┴────────────────────────┴─────────────────────────┘
                                        │
                                  ┌─────┴─────┐
                                  │  MongoDB  │
                                  │  :27017   │
                                  └───────────┘
```

### Microservices

| Service | Port | Database | Responsibility |
|---------|------|----------|----------------|
| User Service | 8001 | user_db | Registration, Login, JWT Auth, Profile |
| Product Catalog | 8002 | product_db | Products listing, Categories, Seed data |
| Cart & Order | 8003 | cart_order_db | Cart management, Order creation & history |
| Delivery Status | 8004 | delivery_db | Delivery lifecycle tracking |

### Authentication
- JWT-based authentication for frontend-facing APIs
- Hardcoded OTP: `1234`
- Internal service-to-service communication is trusted (no JWT)

### Status Flow
```
PLACED → PACKED → OUT_FOR_DELIVERY → DELIVERED
```

---

## Project Structure

```
project/
├── docker-compose.yml
├── k8s/
│   ├── mongo.yaml
│   ├── user-service.yaml
│   ├── product-service.yaml
│   ├── cart-order-service.yaml
│   └── delivery-service.yaml
├── services/
│   ├── user-service/
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   ├── .env.example
│   │   └── app/
│   │       ├── __init__.py
│   │       ├── main.py
│   │       ├── config.py
│   │       ├── database.py
│   │       ├── models.py
│   │       ├── auth.py
│   │       └── routes.py
│   ├── product-service/
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   ├── .env.example
│   │   └── app/
│   │       ├── __init__.py
│   │       ├── main.py
│   │       ├── config.py
│   │       ├── database.py
│   │       ├── models.py
│   │       ├── routes.py
│   │       └── seed.py
│   ├── cart-order-service/
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   ├── .env.example
│   │   └── app/
│   │       ├── __init__.py
│   │       ├── main.py
│   │       ├── config.py
│   │       ├── database.py
│   │       ├── models.py
│   │       ├── auth.py
│   │       └── routes.py
│   └── delivery-service/
│       ├── Dockerfile
│       ├── requirements.txt
│       ├── .env.example
│       └── app/
│           ├── __init__.py
│           ├── main.py
│           ├── config.py
│           ├── database.py
│           ├── models.py
│           ├── auth.py
│           └── routes.py
├── flutter_app/
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   └── lib/
│       ├── main.dart
│       ├── config/
│       │   └── api_config.dart
│       ├── models/
│       │   ├── product.dart
│       │   └── order.dart
│       ├── services/
│       │   └── api_service.dart
│       ├── providers/
│       │   ├── auth_provider.dart
│       │   └── cart_provider.dart
│       └── screens/
│           ├── login_screen.dart
│           ├── signup_screen.dart
│           ├── home_screen.dart
│           ├── product_detail_screen.dart
│           ├── cart_screen.dart
│           ├── order_confirmation_screen.dart
│           └── order_tracking_screen.dart
└── README.md
```

---

## How to Run Locally (Docker)

### Prerequisites
- Docker & Docker Compose installed

### Steps

```bash
cd project
docker-compose up --build
```

This starts:
- MongoDB on port 27017
- User Service on port 8001
- Product Catalog on port 8002
- Cart & Order Service on port 8003
- Delivery Service on port 8004

Product seed data is automatically loaded on first startup.

### Test APIs

```bash
# Register
curl -X POST http://localhost:8001/register \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@test.com","password":"pass123"}'

# Login (OTP is always 1234)
curl -X POST http://localhost:8001/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@test.com","password":"pass123","otp":"1234"}'

# Get products
curl http://localhost:8002/products

# Get categories
curl http://localhost:8002/categories
```

---

## How to Run in Kubernetes

### Prerequisites
- kubectl configured
- Docker images built and pushed to a registry

### Build & Push Images

```bash
cd project/services/user-service
docker build -t quickcommerce/user-service:latest .

cd ../product-service
docker build -t quickcommerce/product-service:latest .

cd ../cart-order-service
docker build -t quickcommerce/cart-order-service:latest .

cd ../delivery-service
docker build -t quickcommerce/delivery-service:latest .
```

Push to your registry (e.g., Docker Hub, ECR, GCR).

### Deploy

```bash
kubectl apply -f k8s/mongo.yaml
kubectl apply -f k8s/user-service.yaml
kubectl apply -f k8s/product-service.yaml
kubectl apply -f k8s/cart-order-service.yaml
kubectl apply -f k8s/delivery-service.yaml
```

### Port Forward for Testing

```bash
kubectl port-forward svc/user-service 8001:8001
kubectl port-forward svc/product-service 8002:8002
kubectl port-forward svc/cart-order-service 8003:8003
kubectl port-forward svc/delivery-service 8004:8004
```

---

## Flutter App

### Setup

```bash
cd project/flutter_app
flutter pub get
flutter run
```

### Configuration

Edit `lib/config/api_config.dart` to set your backend URLs:
- Android emulator: `http://10.0.2.2:<port>`
- iOS simulator: `http://localhost:<port>`
- Physical device: use your machine's IP

---

## Assumptions

1. OTP is hardcoded to `1234` (no SMS integration)
2. All payments are assumed prepaid (no payment gateway)
3. No admin panel
4. No API gateway (services are accessed directly)
5. Internal service communication is trusted (no JWT between services)
6. MongoDB runs without authentication (dev mode)
7. Product images use placeholder URLs

## Known Limitations

1. No rate limiting or request throttling
2. No centralized logging or monitoring
3. No CI/CD pipeline
4. MongoDB has no persistent volume in Kubernetes (uses emptyDir)
5. JWT secret is hardcoded in env vars (use K8s Secrets in production)
6. No WebSocket support for real-time delivery tracking
7. No image upload functionality
8. Cart syncs to backend only at order time (local-first in Flutter)
