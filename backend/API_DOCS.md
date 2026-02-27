# SmartPack API Documentation

**Base URL:** `http://127.0.0.1:8000` (Local Development)

All API endpoints require authentication except registration and login.

---

## Table of Contents

- [Authentication](#authentication)
- [User Profile](#user-profile)
- [Trips](#trips)
- [Weather](#weather)
- [Packing](#packing)

---

## Authentication

### Register

Create a new user account.

**Endpoint:** `POST /api/users/register/`

**Authentication:** None (public endpoint)

**Request Body:**
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "securepass123",
  "date_of_birth": "1995-05-15",
  "gender": "male"
}
```

**Response:** `201 Created`
```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "date_of_birth": "1995-05-15",
  "gender": "male",
  "age": 28,
  "preferences": {}
}
```

**Possible Errors:**
- `400 Bad Request` - Invalid data (missing fields, weak password, etc.)

---

### Login

Get access and refresh tokens.

**Endpoint:** `POST /api/auth/login/`

**Authentication:** None (public endpoint)

**Request Body:**
```json
{
  "username": "john_doe",
  "password": "securepass123"
}
```

**Response:** `200 OK`
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Token Lifetimes:**
- Access token: 1 day
- Refresh token: 30 days

**Possible Errors:**
- `401 Unauthorized` - Invalid credentials

---

### Refresh Token

Get a new access token using refresh token.

**Endpoint:** `POST /api/auth/refresh/`

**Authentication:** None

**Request Body:**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Response:** `200 OK`
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Possible Errors:**
- `401 Unauthorized` - Invalid or expired refresh token

---

## User Profile

All profile endpoints require authentication.

**Authentication Header:**
```
Authorization: Bearer {access_token}
```

### Get Current User Profile

**Endpoint:** `GET /api/users/profile/`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "date_of_birth": "1995-05-15",
  "gender": "male",
  "age": 28,
  "preferences": {
    "theme": "dark",
    "notifications": true
  }
}
```

---

### Update User Profile

**Endpoint:** `PATCH /api/users/profile/`

**Authentication:** Required

**Request Body:** (all fields optional)
```json
{
  "gender": "female",
  "date_of_birth": "1990-01-01",
  "preferences": {
    "theme": "light",
    "notifications": false
  }
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "date_of_birth": "1990-01-01",
  "gender": "female",
  "age": 35,
  "preferences": {
    "theme": "light",
    "notifications": false
  }
}
```

**Note:** `username` and `email` are read-only and cannot be changed.

---

## Trips

All trip endpoints require authentication.

### List All Trips

Get all trips for the authenticated user.

**Endpoint:** `GET /api/trips/`

**Authentication:** Required

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "name": "London 2026",
    "destination": "London",
    "start_date": "2026-03-01",
    "end_date": "2026-03-05",
    "trip_type": "city",
    "luggage_type": "backpack",
    "duration_days": 5,
    "created_at": "2026-02-09T00:45:38.241196Z",
    "user": 1
  },
  {
    "id": 2,
    "name": "Miami Beach Trip",
    "destination": "Miami",
    "start_date": "2026-06-15",
    "end_date": "2026-06-20",
    "trip_type": "beach",
    "luggage_type": "large_suitcase",
    "duration_days": 6,
    "created_at": "2026-02-09T10:30:00.000000Z",
    "user": 1
  }
]
```

---

### Get Trip Details

**Endpoint:** `GET /api/trips/{id}/`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "id": 1,
  "name": "London 2026",
  "destination": "London",
  "start_date": "2026-03-01",
  "end_date": "2026-03-05",
  "trip_type": "city",
  "luggage_type": "backpack",
  "duration_days": 5,
  "created_at": "2026-02-09T00:45:38.241196Z",
  "user": 1
}
```

**Possible Errors:**
- `404 Not Found` - Trip doesn't exist or doesn't belong to user

---

### Create Trip

**Endpoint:** `POST /api/trips/`

**Authentication:** Required

**Request Body:**
```json
{
  "destination": "Paris",
  "start_date": "2026-07-10",
  "end_date": "2026-07-15",
  "trip_type": "city",
  "luggage_type": "small_suitcase",
  "name": "Paris Summer Trip"
}
```

**Field Options:**

**`trip_type`** (required):
- `city` - City trip
- `beach` - Beach vacation
- `mountain` - Mountain/hiking trip
- `business` - Business trip

**`luggage_type`** (required):
- `backpack` - Backpack
- `small_suitcase` - Small suitcase (≤ 10kg)
- `large_suitcase` - Large suitcase (> 10kg)

**`name`** (optional):
- If not provided, auto-generated as: `{destination} {year}`

**Response:** `201 Created`
```json
{
  "id": 3,
  "name": "Paris Summer Trip",
  "destination": "Paris",
  "start_date": "2026-07-10",
  "end_date": "2026-07-15",
  "trip_type": "city",
  "luggage_type": "small_suitcase",
  "duration_days": 6,
  "created_at": "2026-02-09T15:00:00.000000Z",
  "user": 1
}
```

**Possible Errors:**
- `400 Bad Request` - Invalid data (end_date before start_date, invalid trip_type, etc.)

---

### Update Trip

**Endpoint:** `PATCH /api/trips/{id}/`

**Authentication:** Required

**Request Body:** (all fields optional)
```json
{
  "name": "Updated Trip Name",
  "end_date": "2026-07-20"
}
```

**Response:** `200 OK`
```json
{
  "id": 3,
  "name": "Updated Trip Name",
  "destination": "Paris",
  "start_date": "2026-07-10",
  "end_date": "2026-07-20",
  "trip_type": "city",
  "luggage_type": "small_suitcase",
  "duration_days": 11,
  "created_at": "2026-02-09T15:00:00.000000Z",
  "user": 1
}
```

**Possible Errors:**
- `400 Bad Request` - Cannot modify past trips
- `404 Not Found` - Trip doesn't exist

---

### Delete Trip

**Endpoint:** `DELETE /api/trips/{id}/`

**Authentication:** Required

**Response:** `204 No Content`

**Possible Errors:**
- `404 Not Found` - Trip doesn't exist

---

## Weather

Get weather forecast for a trip destination.

### Get Weather for Trip

Fetches weather data from OpenWeatherMap API and caches it.

**Endpoint:** `GET /api/weather/{trip_id}/`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "id": 1,
  "trip": 1,
  "temperature": 8.32,
  "condition": "clouds",
  "humidity": 92,
  "wind_speed": 2.06,
  "is_rainy": false,
  "is_sunny": false,
  "is_snowy": false,
  "is_windy": false,
  "api_source": "openweathermap",
  "fetched_at": "2026-02-09T01:00:00.000000Z"
}
```

**Fields:**

- `temperature` - Temperature in Celsius
- `condition` - Weather condition (clear, clouds, rain, snow, etc.)
- `humidity` - Humidity percentage (0-100)
- `wind_speed` - Wind speed in m/s
- `is_rainy` - Boolean helper (condition is rain/drizzle/thunderstorm)
- `is_sunny` - Boolean helper (condition is clear)
- `is_snowy` - Boolean helper (condition is snow)
- `is_windy` - Boolean helper (wind_speed > 10 m/s)

**Note:** Weather data is cached. Subsequent requests return cached data unless manually refreshed.

**Possible Errors:**
- `404 Not Found` - Trip doesn't exist
- `500 Internal Server Error` - Weather API error

---

## Packing

Manage packing items and get AI-powered suggestions.

### List Available Packing Items

Get the master list of all packing items.

**Endpoint:** `GET /api/packing/items/`

**Authentication:** Optional (public data)

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "name": "Passport",
    "category": "Documents"
  },
  {
    "id": 2,
    "name": "Phone Charger",
    "category": "Electronics"
  },
  {
    "id": 3,
    "name": "Swimsuit",
    "category": "Clothing"
  }
]
```

---

### Get Packing List for Trip

**Endpoint:** `GET /api/packing/trip-items/?trip={trip_id}`

**Authentication:** Required

**Query Parameters:**
- `trip` - Trip ID (required)

**Example:** `GET /api/packing/trip-items/?trip=1`

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "trip": 1,
    "item": {
      "id": 5,
      "name": "Sunscreen",
      "category": "Toiletries"
    },
    "quantity": 1,
    "is_checked": false
  },
  {
    "id": 2,
    "trip": 1,
    "item": {
      "id": 12,
      "name": "Camera",
      "category": "Electronics"
    },
    "quantity": 1,
    "is_checked": true
  }
]
```

---

### Get AI Packing Suggestions

Get smart packing suggestions based on trip type, weather, and duration.

**Endpoint:** `POST /api/packing/trip-items/suggest/`

**Authentication:** Required

**Request Body:**
```json
{
  "trip_id": 1
}
```

**Response:** `200 OK`
```json
{
  "trip_id": 1,
  "suggestions": [
    "passport",
    "phone_charger",
    "toiletries",
    "comfortable_shoes",
    "camera",
    "umbrella",
    "sweater",
    "jacket",
    "10_underwear",
    "6_socks",
    "compact_items_only"
  ],
  "count": 11
}
```

**Suggestion Logic:**
- Base items (passport, charger, toiletries) for all trips
- Trip-type specific items (swimsuit for beach, hiking boots for mountain, etc.)
- Weather-based items (umbrella if rainy, sunscreen if sunny, jacket if cold)
- Duration-based quantities (2x underwear per day, days+1 socks)
- Luggage reminders (compact items for backpack)

**Possible Errors:**
- `404 Not Found` - Trip doesn't exist

---

### Add Item to Packing List

**Endpoint:** `POST /api/packing/trip-items/`

**Authentication:** Required

**Request Body:**
```json
{
  "trip": 1,
  "item_id": 5,
  "quantity": 2
}
```

**Response:** `201 Created`
```json
{
  "id": 3,
  "trip": 1,
  "item": {
    "id": 5,
    "name": "Sunscreen",
    "category": "Toiletries"
  },
  "quantity": 2,
  "is_checked": false
}
```

**Possible Errors:**
- `400 Bad Request` - Item already exists for this trip

---

### Update Packing Item

**Endpoint:** `PATCH /api/packing/trip-items/{id}/`

**Authentication:** Required

**Request Body:** (all fields optional)
```json
{
  "quantity": 3,
  "is_checked": true
}
```

**Response:** `200 OK`
```json
{
  "id": 3,
  "trip": 1,
  "item": {
    "id": 5,
    "name": "Sunscreen",
    "category": "Toiletries"
  },
  "quantity": 3,
  "is_checked": true
}
```

---

### Delete Packing Item

**Endpoint:** `DELETE /api/packing/trip-items/{id}/`

**Authentication:** Required

**Response:** `204 No Content`

---

## Error Responses

All endpoints may return these error responses:

### 400 Bad Request
```json
{
  "field_name": [
    "Error message describing the issue"
  ]
}
```

### 401 Unauthorized
```json
{
  "detail": "Authentication credentials were not provided."
}
```

or
```json
{
  "detail": "Given token not valid for any token type",
  "code": "token_not_valid"
}
```

### 403 Forbidden
```json
{
  "detail": "You do not have permission to perform this action."
}
```

### 404 Not Found
```json
{
  "detail": "Not found."
}
```

### 500 Internal Server Error
```json
{
  "detail": "A server error occurred."
}
```

---

## Rate Limits

Currently no rate limits are enforced in development.

Production rate limits (when deployed):
- Authentication endpoints: 5 requests per minute
- All other endpoints: 100 requests per minute per user

---

## Notes for Frontend Developers

### Authentication Flow

1. User registers: `POST /api/users/register/`
2. User logs in: `POST /api/auth/login/` → Get `access` and `refresh` tokens
3. Store both tokens securely (Flutter secure storage)
4. Include `Authorization: Bearer {access_token}` in all subsequent requests
5. When access token expires (401 error), use refresh token: `POST /api/auth/refresh/`
6. Get new access token and retry original request

### Typical User Flow
```
1. Register/Login → Get tokens
2. Create trip → POST /api/trips/
3. Get weather → GET /api/weather/{trip_id}/
4. Get packing suggestions → POST /api/packing/trip-items/suggest/
5. Add items to packing list → POST /api/packing/trip-items/
6. Check off items → PATCH /api/packing/trip-items/{id}/
```

### Testing

Use these test credentials:
- Username: `admin`
- Password: `admin123`

Or create your own via `/api/users/register/`

---

## Support

For questions or issues:
- Check this documentation first
- Ask in team Slack/Discord
- Contact backend team