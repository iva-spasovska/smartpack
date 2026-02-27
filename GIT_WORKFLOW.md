# Git Workflow

## Branch Strategy
```
main (production-ready code)
  ↓
develop (integration branch)
  ↓
feature/* (individual features)
```

## Branches

### `main`
- **Protected branch**
- Production-ready code only
- Only merge from `develop` after testing
- Tagged releases (v1.0, v1.1, etc.)

### `develop`
- **Integration branch**
- All features merge here first
- Should always be stable
- Test thoroughly before merging to `main`

### `feature/*`
- **Individual features**
- Naming: `feature/backend-ml-model`, `feature/frontend-login-screen`
- Create from `develop`
- Merge back to `develop` when done

### Example Feature Branches
- `feature/backend-ml-model` (You - ML model)
- `feature/frontend-trip-list` (Frontend dev - Trip list UI)
- `feature/frontend-auth` (Frontend dev - Login/Register)
- `feature/backend-notifications` (You - Push notifications)

## Workflow

### Starting a New Feature
```bash
# 1. Make sure you're on develop and up to date
git checkout develop
git pull origin develop

# 2. Create feature branch
git checkout -b feature/backend-ml-model

# 3. Work on your feature
# ... make changes ...

# 4. Commit regularly
git add .
git commit -m "Add ML model training script"

# 5. Push to remote
git push origin feature/backend-ml-model
```

### Merging Feature to Develop
```bash
# 1. Make sure your branch is up to date
git checkout feature/backend-ml-model
git pull origin develop  # Get latest changes from develop
git merge develop        # Merge develop into your branch

# 2. Resolve any conflicts

# 3. Push your branch
git push origin feature/backend-ml-model

# 4. Create Pull Request on GitHub
# Go to GitHub → Pull Requests → New PR
# From: feature/backend-ml-model → To: develop

# 5. After PR is approved and merged, delete feature branch
git checkout develop
git pull origin develop
git branch -d feature/backend-ml-model
```