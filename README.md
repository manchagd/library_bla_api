# Library Bla API

This project is a Rails API application for managing library resources.

## 1. Installation From Scratch

To set up the application from a clean environment:

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
```

## 2. Running the Application

### Development Mode
```bash
rails server
```
The API will be available at `http://localhost:3000`.

### Test Mode
To run the test suite:
```bash
bundle exec rspec
```

## 3. Architecture, Design & Conventions

### High-Level Architecture
This project follows a strict **Service-Oriented Architecture** within Rails:
- **Controllers**: Thin layer, responsible only for HTTP translation and calling EntryPoints.
- **Interactors**: All business logic resides in `app/interactors`.
- **EntryPoints**: Public interface for business logic, located in `app/services/request_entry_point.rb`.

### Directories
- `app/interactors`: Contains `BaseService` (single action) and `BasePipeline` (organizers).
- `app/errors`: Domain-specific error classes.
- `app/services`: Request Entry Points.

### Conventions
- **Error Handling**: Centralized in `ApplicationController` via `ErrorHandling` concern.
- **Serialization**: Uses `Blueprinter`. All responses match `{ data: ..., errors: ... }`.

## 4. API Documentation & Guidelines

### Responses
All API endpoints return JSON in the following format:
```json
{
  "data": { ... },
  "errors": []
}
```

### Adding New Endpoints
1. Define the route.
2. Create a `RequestEntryPoint` wrapper.
3. Implement the logic in an Interactor.
4. Call the EntryPoint from the Controller.
