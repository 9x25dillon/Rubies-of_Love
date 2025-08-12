# CarryOn - Portable AI Identity for Everyday People

This is a Ruby on Rails implementation of the CarryOn system for portable AI identity.

## Features

- Soulpack management (persona, preferences, signing)
- Memory events with sensitivity and consent tracking
- Primer generation for LLM sessions
- RESTful API for all functionality
- SQLite database storage
- CORS support for frontend integration

## Setup

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Create and migrate the database:
   ```bash
   rails db:create
   rails db:migrate
   ```

3. Start the server:
   ```bash
   rails server
   ```

## API Endpoints

- `GET /api/v1/health` - Health check
- `POST /api/v1/soulpacks` - Import soulpack
- `GET /api/v1/soulpacks` - Export soulpack
- `POST /api/v1/memories` - Add memories
- `GET /api/v1/memories` - List memories
- `POST /api/v1/prime` - Generate session primer
- `GET /api/v1/tools` - List tools
- `POST /api/v1/tools` - Register/update tool

## Development

Run tests:
```bash
rspec
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a pull request
