# Python Backend Technical Preferences

**Stack:** FastAPI + SQLAlchemy + Alembic + Pydantic + PostgreSQL + pytest

---

## Project Structure

```
app/
  api/
    v1/
      endpoints/       # Route handlers
        users.py
        auth.py
  core/
    config.py         # Settings (Pydantic BaseSettings)
    security.py       # Auth utilities
  models/             # SQLAlchemy models
    user.py
  schemas/            # Pydantic schemas
    user.py
  services/           # Business logic
    user_service.py
  db/
    base.py          # Import all models
    session.py       # Database session
alembic/            # Migration files
tests/              # All tests here
```

---

## Critical Conventions

### Naming

**Router Functions (CRITICAL):**
```python
# CRUD pattern - always this order
async def get_user()       # READ one
async def get_users()      # READ many
async def create_user()    # CREATE
async def update_user()    # UPDATE
async def delete_user()    # DELETE
```

**Schema Classes (REQUIRED):**
```python
class UserBase(BaseModel):      # Shared attributes
class UserCreate(UserBase):     # POST requests
class UserUpdate(UserBase):     # PUT/PATCH requests
class UserResponse(UserBase):   # API responses
class UserInDB(UserBase):       # Database representation
```

**Service Functions:**
```python
# Business logic - end with _service
def create_user_service()
def get_user_service()
def update_user_service()
```

**Files:**
- snake_case for all Python files
- Singular nouns: `user.py` not `users.py` (except endpoints)

### Database Models (SQLAlchemy)

**User ID Convention (CRITICAL):**
```python
id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
# Always UUID, never integer
```

**Required Fields:**
```python
created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
```

**Relationships:**
```python
# Use back_populates, not backref
user: Mapped["User"] = relationship("User", back_populates="posts")
posts: Mapped[list["Post"]] = relationship("Post", back_populates="user", cascade="all, delete-orphan")
```

**String Columns:**
```python
# Always specify length for strings
name: Mapped[str] = mapped_column(String(255), nullable=False)
```

### Pydantic Schemas

**Response Models (REQUIRED):**
```python
class UserResponse(BaseModel):
    id: UUID
    email: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)  # Enable ORM mode
```

**Validation:**
```python
# Use Field for constraints
from pydantic import Field

class UserCreate(BaseModel):
    email: str = Field(..., max_length=255)
    password: str = Field(..., min_length=8)
```

### API Endpoints

**Response Model (ALWAYS SPECIFY):**
```python
@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: UUID, db: AsyncSession = Depends(get_db)):
    ...
```

**Status Codes:**
```python
# Explicit status codes for creates
@router.post("/users", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(...):
    ...
```

**Dependency Injection:**
```python
# Use Depends for database, auth, etc.
async def get_user(
    user_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    ...
```

### Async/Await

**Database Operations (REQUIRED):**
```python
# Always use async for database operations
async with AsyncSession(engine) as session:
    result = await session.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
```

**Service Layer:**
```python
# Services should be async
async def create_user_service(db: AsyncSession, user_create: UserCreate) -> User:
    user = User(**user_create.model_dump())
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user
```

### Error Handling

**Custom Exceptions:**
```python
# app/core/exceptions.py
class NotFoundException(Exception):
    pass

class UnauthorizedException(Exception):
    pass
```

**Exception Handlers:**
```python
# Register in main.py
@app.exception_handler(NotFoundException)
async def not_found_handler(request: Request, exc: NotFoundException):
    return JSONResponse(
        status_code=status.HTTP_404_NOT_FOUND,
        content={"detail": str(exc)}
    )
```

**Usage in Endpoints:**
```python
user = await get_user_service(db, user_id)
if not user:
    raise NotFoundException(f"User {user_id} not found")
```

### Configuration

**Settings (Pydantic BaseSettings):**
```python
# app/core/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str

    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True
    )

settings = Settings()
```

**Usage:**
```python
from app.core.config import settings

database_url = settings.DATABASE_URL
```

### Testing (pytest)

**File Naming:**
```python
# tests/test_users.py (prefix with test_)
# tests/conftest.py (fixtures)
```

**Async Tests:**
```python
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_create_user(client: AsyncClient):
    response = await client.post("/api/v1/users", json={"email": "test@test.com"})
    assert response.status_code == 201
```

**Fixtures:**
```python
# tests/conftest.py
@pytest.fixture
async def db_session():
    # Setup test database
    async with AsyncSession(test_engine) as session:
        yield session
        await session.rollback()
```

### Migrations (Alembic)

**Never Manual:**
```bash
# Generate migrations automatically
alembic revision --autogenerate -m "Add users table"
alembic upgrade head
```

**Import All Models:**
```python
# app/db/base.py
# Import all models here so Alembic can detect them
from app.models.user import User
from app.models.post import Post
```

---

## What to AVOID

❌ Using `backref` (use `back_populates`)
❌ Integer IDs (use UUID)
❌ Sync functions for database operations (use async)
❌ Missing `response_model` in endpoints
❌ String columns without length
❌ Manual database migrations
❌ Circular imports (use `"ClassName"` strings in relationships)
❌ Missing type hints
❌ Hardcoded config values (use Settings)

---

## Response Pattern

**Success:**
```python
return UserResponse.model_validate(user)  # Single item
return [UserResponse.model_validate(u) for u in users]  # List
```

**Errors:**
```python
raise HTTPException(
    status_code=status.HTTP_404_NOT_FOUND,
    detail="User not found"
)
```

---

## Notes

- This file contains ONLY your specific preferences/opinions
- General Python/FastAPI best practices are assumed
- Focus: deviations from defaults, not explanations of basics
