# Library Bla API

This project is a Rails API application for managing library resources.

## 1. Installation From Scratch

### System Requirements
- **Ruby**: 3.3.0 (Managed via rbenv/rvm/asdf)
- **SQLite3**: For development/test databases
- **Bundler**: To manage gems

### Setup Commands
```bash
# Clone the repository
git clone <repository_url>
cd library_bla

# Install dependencies
bundle install

# Setup database
rails db:create db:migrate db:seed
```

## 2. Running the Application

### Development Mode
```bash
rails server
```
The API will be available at `http://localhost:3000`.

### Test Mode
```bash
bundle exec rspec
bundle exec rubocop
```

### Using ngrok
ngrok is pre-configured. Just run:
```bash
ngrok http 3000
```

## 3. Architecture, Design & Conventions

### High-Level Architecture
- **Controllers**: Thin layer, HTTP translation only. Delegate to `RequestEntryPoint` services.
- **Services**: Business logic in `app/interactors/request_entry_point/<domain>/<action>.rb`.
- **Base Classes**: `BaseService` (single action), `BasePipeline` (organizers).
- **Authentication**: Stateless JWT via `devise-jwt`. Tokens expire in 30 minutes.
- **Authorization**: Role-based access control via `Pundit`.
- **Serialization**: `Blueprinter`. All responses: `{ data: ..., errors: [] }`.

### Directory Structure
```
app/
├── blueprints/           # Serializers (BookBlueprint, BorrowingBlueprint, etc.)
├── controllers/          # Thin controllers
├── interactors/          # BaseService, BasePipeline, RequestEntryPoint/*
├── models/errors/        # Domain-specific errors
└── policies/             # Pundit policies
```

### Adding New Services
1. Create service in `app/interactors/request_entry_point/<domain>/<action>.rb`
2. Inherit from `BaseService`
3. Implement `def call` method
4. Call from controller: `RequestEntryPoint::<Domain>::<Action>.call(...)`

## 4. API Documentation & Guidelines

### Full API Specification

📄 **[API_SPEC.md](API_SPEC.md)** - Complete API documentation with:
- All endpoints with curl examples
- Request/Response formats
- Error handling
- Quick start script
- Permissions matrix

### Swagger UI
Interactive API documentation available at:
```
http://localhost:3000/api-docs
```

### Endpoints Summary

| Method | Path | Description | Role |
|--------|------|-------------|------|
| POST | `/api/v1/auth/login` | Login | Public |
| DELETE | `/api/v1/auth/logout` | Logout | Any |
| GET | `/api/v1/dashboard` | Role-specific dashboard | Any |
| GET | `/api/v1/books` | List/Search books | Any |
| GET | `/api/v1/books/:id` | Show book | Any |
| POST | `/api/v1/books` | Create book | Librarian |
| PATCH | `/api/v1/books/:id` | Update book | Librarian |
| DELETE | `/api/v1/books/:id` | Delete book | Librarian |
| GET | `/api/v1/borrowings` | List borrowings | Any (scoped) |
| GET | `/api/v1/borrowings/:id` | Show borrowing | Any (scoped) |
| POST | `/api/v1/borrowings` | Borrow a book | Member |
| POST | `/api/v1/borrowings/:id/return` | Return book | Librarian |

### Error Handling
Errors use custom classes under `app/models/errors/` and are rescued centrally in `ErrorHandling` concern.

### Test Accounts (from seeds)

| Role | Email | Password |
|------|-------|----------|
| Librarian | librarian@example.com | password |
| Member | member@example.com | password |

## 5. Tips

### Factory Traits (for specs)
- `:librarian` - Creates a librarian user
- `:returned` - Creates a returned borrowing
- `:due_today` - Creates a borrowing due today
- `:overdue` - Creates an overdue borrowing (accepts `days_overdue` transient)
