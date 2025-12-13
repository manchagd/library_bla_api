# Library API Specification

## Base URL

```
Local:  http://localhost:3000
Ngrok:  https://your-subdomain.ngrok.io
```

## Authentication

All endpoints (except login) require a Bearer token in the `Authorization` header.

```
Authorization: Bearer <JWT_TOKEN>
```

---

## Test Credentials (from seeds)

| Role      | Email                    | Password |
|-----------|--------------------------|----------|
| Librarian | librarian@example.com    | password |
| Member    | member@example.com       | password |

---

## Endpoints

### 1. Authentication

#### Login

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "librarian@example.com",
    "password": "password"
  }'
```

**Response (200):**
```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": 1,
      "data_type": "user",
      "email": "librarian@example.com",
      "role": "librarian"
    }
  },
  "errors": []
}
```

**Extract token from response body:**
```bash
TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "librarian@example.com", "password": "password"}' \
  | jq -r '.data.token')

echo $TOKEN
```

#### Logout

```bash
curl -X DELETE http://localhost:3000/api/v1/auth/logout \
  -H "Authorization: Bearer $TOKEN"
```

**Response (200):**
```json
{
  "data": {},
  "errors": []
}
```

---

### 2. Dashboard

#### Get Dashboard (Role-specific)

**Librarian Dashboard:**
```bash
curl -X GET http://localhost:3000/api/v1/dashboard \
  -H "Authorization: Bearer $LIBRARIAN_TOKEN"
```

**Response (200):**
```json
{
  "data": {
    "data_type": "librarian_dashboard",
    "total_books": 200,
    "total_borrowed_books": 285,
    "books_due_today": 10,
    "members_with_overdue_books": [
      {
        "user_id": 2,
        "email": "member@example.com",
        "overdue_count": 5,
        "overdue_books": ["Book Title 1", "Book Title 2"]
      }
    ]
  },
  "errors": []
}
```

**Member Dashboard:**
```bash
curl -X GET http://localhost:3000/api/v1/dashboard \
  -H "Authorization: Bearer $MEMBER_TOKEN"
```

**Response (200):**
```json
{
  "data": {
    "data_type": "member_dashboard",
    "active_borrowings": [
      {
        "id": 1,
        "book_id": 5,
        "book_title": "The Great Gatsby",
        "borrowed_at": "2024-12-01T10:00:00Z",
        "due_at": "2024-12-15T10:00:00Z",
        "overdue": false
      }
    ],
    "overdue_borrowings": [
      {
        "id": 2,
        "book_id": 10,
        "book_title": "1984",
        "due_at": "2024-12-10T10:00:00Z",
        "days_overdue": 3
      }
    ],
    "overdue_count": 1
  },
  "errors": []
}
```

---

### 3. Books

#### List Books

```bash
curl -X GET "http://localhost:3000/api/v1/books" \
  -H "Authorization: Bearer $TOKEN"
```

**With search query:**
```bash
curl -X GET "http://localhost:3000/api/v1/books?query=gatsby" \
  -H "Authorization: Bearer $TOKEN"
```

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "data_type": "book",
      "title": "The Great Gatsby",
      "author": "F. Scott Fitzgerald",
      "genre": "Fiction",
      "isbn": "978-0-7432-7356-5",
      "total_copies": 5,
      "created_at": "2024-12-13T10:00:00Z",
      "updated_at": "2024-12-13T10:00:00Z"
    }
  ],
  "errors": [],
  "meta": {
    "page": 1,
    "items": 20,
    "count": 200,
    "pages": 10
  }
}
```

#### Get Book

```bash
curl -X GET http://localhost:3000/api/v1/books/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Response (200):**
```json
{
  "data": {
    "id": 1,
    "data_type": "book",
    "title": "The Great Gatsby",
    "author": "F. Scott Fitzgerald",
    "genre": "Fiction",
    "isbn": "978-0-7432-7356-5",
    "total_copies": 5,
    "created_at": "2024-12-13T10:00:00Z",
    "updated_at": "2024-12-13T10:00:00Z"
  },
  "errors": []
}
```

#### Create Book (Librarian only)

```bash
curl -X POST http://localhost:3000/api/v1/books \
  -H "Authorization: Bearer $LIBRARIAN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "book": {
      "title": "New Book",
      "author": "Author Name",
      "genre": "Fiction",
      "isbn": "978-1-234567-89-0",
      "total_copies": 3
    }
  }'
```

**Response (201):**
```json
{
  "data": {
    "id": 201,
    "data_type": "book",
    "title": "New Book",
    "author": "Author Name",
    "genre": "Fiction",
    "isbn": "978-1-234567-89-0",
    "total_copies": 3,
    "created_at": "2024-12-13T12:00:00Z",
    "updated_at": "2024-12-13T12:00:00Z"
  },
  "errors": []
}
```

#### Update Book (Librarian only)

```bash
curl -X PATCH http://localhost:3000/api/v1/books/1 \
  -H "Authorization: Bearer $LIBRARIAN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "book": {
      "total_copies": 10
    }
  }'
```

#### Delete Book (Librarian only)

```bash
curl -X DELETE http://localhost:3000/api/v1/books/1 \
  -H "Authorization: Bearer $LIBRARIAN_TOKEN"
```

**Response (204):** No content

---

### 4. Borrowings

#### List Borrowings

**Librarian:** sees all borrowings
**Member:** sees only their own borrowings

```bash
curl -X GET http://localhost:3000/api/v1/borrowings \
  -H "Authorization: Bearer $TOKEN"
```

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "data_type": "borrowing",
      "status": "active",
      "borrowed_at": "2024-12-01T10:00:00Z",
      "due_at": "2024-12-15T10:00:00Z",
      "returned_at": null,
      "user_id": 2,
      "book_id": 5,
      "created_at": "2024-12-01T10:00:00Z",
      "updated_at": "2024-12-01T10:00:00Z",
      "book": {
        "id": 5,
        "data_type": "book",
        "title": "The Great Gatsby",
        "author": "F. Scott Fitzgerald",
        "genre": "Fiction",
        "isbn": "978-0-7432-7356-5",
        "total_copies": 5
      }
    }
  ],
  "errors": [],
  "meta": {
    "page": 1,
    "items": 20,
    "count": 50,
    "pages": 3
  }
}
```

#### Get Borrowing

```bash
curl -X GET http://localhost:3000/api/v1/borrowings/1 \
  -H "Authorization: Bearer $TOKEN"
```

#### Create Borrowing (Member only)

```bash
curl -X POST http://localhost:3000/api/v1/borrowings \
  -H "Authorization: Bearer $MEMBER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "borrowing": {
      "book_id": 1
    }
  }'
```

**Response (201):**
```json
{
  "data": {
    "id": 100,
    "data_type": "borrowing",
    "status": "active",
    "borrowed_at": "2024-12-13T12:00:00Z",
    "due_at": "2024-12-27T12:00:00Z",
    "returned_at": null,
    "user_id": 2,
    "book_id": 1,
    "book": { ... }
  },
  "errors": []
}
```

**Error - Book not available (422):**
```json
{
  "data": {},
  "errors": [
    {
      "code": "book_not_available",
      "detail": "Book is not available for borrowing"
    }
  ]
}
```

**Error - Already borrowed (409):**
```json
{
  "data": {},
  "errors": [
    {
      "code": "already_borrowed",
      "detail": "You already have an active borrowing for this book"
    }
  ]
}
```

#### Return Borrowing (Librarian only)

```bash
curl -X POST http://localhost:3000/api/v1/borrowings/1/return \
  -H "Authorization: Bearer $LIBRARIAN_TOKEN"
```

**Response (200):**
```json
{
  "data": {
    "id": 1,
    "data_type": "borrowing",
    "status": "returned",
    "borrowed_at": "2024-12-01T10:00:00Z",
    "due_at": "2024-12-15T10:00:00Z",
    "returned_at": "2024-12-13T12:00:00Z",
    "user_id": 2,
    "book_id": 5,
    "book": { ... }
  },
  "errors": []
}
```

**Error - Not active (422):**
```json
{
  "data": {},
  "errors": [
    {
      "code": "borrowing_not_active",
      "detail": "Borrowing is not active"
    }
  ]
}
```

---

## Error Responses

### 401 Unauthorized
```json
{
  "data": {},
  "errors": [
    {
      "code": "unauthorized",
      "detail": "Invalid or missing token"
    }
  ]
}
```

### 403 Forbidden
```json
{
  "data": {},
  "errors": [
    {
      "code": "forbidden",
      "detail": "You are not authorized to perform this action"
    }
  ]
}
```

### 404 Not Found
```json
{
  "data": {},
  "errors": [
    {
      "code": "not_found",
      "detail": "Couldn't find Book with 'id'=999"
    }
  ]
}
```

### 422 Unprocessable Entity
```json
{
  "data": {},
  "errors": [
    {
      "code": "unprocessable_entity",
      "detail": "Title can't be blank"
    }
  ]
}
```

---

## Quick Start Script

```bash
#!/bin/bash
BASE_URL="http://localhost:3000"

# Login as Librarian
echo "=== Logging in as Librarian ==="
LIBRARIAN_TOKEN=$(curl -s -X POST "$BASE_URL/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "librarian@example.com", "password": "password"}' \
  | jq -r '.data.token')
echo "Librarian Token: $LIBRARIAN_TOKEN"

# Login as Member
echo "=== Logging in as Member ==="
MEMBER_TOKEN=$(curl -s -X POST "$BASE_URL/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "member@example.com", "password": "password"}' \
  | jq -r '.data.token')
echo "Member Token: $MEMBER_TOKEN"

# Get Librarian Dashboard
echo "=== Librarian Dashboard ==="
curl -s "$BASE_URL/api/v1/dashboard" \
  -H "Authorization: Bearer $LIBRARIAN_TOKEN" | jq

# Get Member Dashboard
echo "=== Member Dashboard ==="
curl -s "$BASE_URL/api/v1/dashboard" \
  -H "Authorization: Bearer $MEMBER_TOKEN" | jq

# List Books
echo "=== Books ==="
curl -s "$BASE_URL/api/v1/books" \
  -H "Authorization: Bearer $LIBRARIAN_TOKEN" | jq

# List Borrowings
echo "=== Borrowings ==="
curl -s "$BASE_URL/api/v1/borrowings" \
  -H "Authorization: Bearer $LIBRARIAN_TOKEN" | jq
```

---

## Swagger UI

Interactive API documentation available at:

```
http://localhost:3000/api-docs
```

---

## Permissions Matrix

| Endpoint                    | Librarian | Member |
|-----------------------------|-----------|--------|
| GET /dashboard              | ✅ (all stats) | ✅ (own borrowings) |
| GET /books                  | ✅        | ✅     |
| GET /books/:id              | ✅        | ✅     |
| POST /books                 | ✅        | ❌     |
| PATCH /books/:id            | ✅        | ❌     |
| DELETE /books/:id           | ✅        | ❌     |
| GET /borrowings             | ✅ (all)  | ✅ (own) |
| GET /borrowings/:id         | ✅        | ✅ (own) |
| POST /borrowings            | ❌        | ✅     |
| POST /borrowings/:id/return | ✅        | ❌     |
