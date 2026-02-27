# SmartPack - Smart Packing Assistant

AI-powered mobile app that helps travelers pack efficiently based on trip details, weather forecasts, and personal preferences.

## Project Structure
```
smartpack/
├── backend/          # Django REST API
│   ├── backend/      # Django config + apps (users, trips, etc.)
│   ├── manage.py
│   └── ...
└── frontend/         # Flutter mobile app
```

## Quick Start

### Prerequisites
- Python 3.9+
- Flutter 3.0+
- Git

### Backend Setup

1. Navigate to backend folder:
```bash
cd backend
```

2. Create virtual environment:
```bash
python -m venv .venv
```

3. Activate virtual environment:
```bash
# Windows
.venv\Scripts\activate

# Mac/Linux
source .venv/bin/activate
```

4. Install dependencies:
```bash
pip install -r requirements.txt
```

5. Create `.env` file:
```bash
cp .env.example .env
# Edit .env and add your API keys
```

6. Run migrations:
```bash
python manage.py migrate
```

7. Create superuser (optional):
```bash
python manage.py createsuperuser
```

8. Run development server:
```bash
python manage.py runserver
```

Backend will be running at: `http://127.0.0.1:8000`

### Frontend Setup

1. Navigate to frontend folder:
```bash
cd frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

The app will connect to `http://127.0.0.1:8000` (make sure backend is running!)

## Team Workflow

### Backend Team
- Work in `backend/` folder
- Create feature branches from `develop`
- Test endpoints with Postman before pushing

### Frontend Team
- Work in `frontend/` folder
- Make sure backend is running locally
- Create feature branches from `develop`

## Git Workflow

See `GIT_WORKFLOW.md` for branching strategy.

## Tech Stack

### Backend
- Django 5.2
- Django REST Framework
- PostgreSQL (production) / SQLite (development)
- JWT Authentication

### Frontend
- Flutter 3.x
- Dart