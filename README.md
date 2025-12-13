# Library Bla API

This project is a Rails API application for managing library resources.

## 1. Installation From Scratch

### System Requirements
- **Ruby**: 3.x (Managed via rbenv/rvm/asdf)
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
├── blueprints/           # Serializers (BookBlueprint, UserBlueprint)
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

### Swagger UI
API documentation available at `/api-docs`.

### Endpoints

| Method | Path | Description | Auth Required | Role |
|--------|------|-------------|---------------|------|
| POST | `/api/v1/auth/login` | Login | No | - |
| DELETE | `/api/v1/auth/logout` | Logout | Yes | - |
| GET | `/api/v1/books` | List/Search books | Yes | Any |
| GET | `/api/v1/books?query=...` | Search by title/author/genre | Yes | Any |
| GET | `/api/v1/books/:id` | Show book | Yes | Any |
| POST | `/api/v1/books` | Create book | Yes | Librarian |
| PATCH | `/api/v1/books/:id` | Update book | Yes | Librarian |
| DELETE | `/api/v1/books/:id` | Delete book | Yes | Librarian |
| GET | `/api/v1/borrowings` | List borrowings | Yes | Any |
| POST | `/api/v1/borrowings` | Create borrowing | Yes | Any |
| PATCH | `/api/v1/borrowings/:id/return_book` | Return book | Yes | Owner/Librarian |

### Error Handling
Errors use custom classes under `app/models/errors/` and are rescued centrally in `ErrorHandling` concern.

### Test Accounts (Development)
- **Librarian**: `librarian@example.com` / `password`
- **Member**: `member@example.com` / `password`
