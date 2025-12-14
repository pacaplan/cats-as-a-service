# Cats-as-a-Service

A demo application showcasing the [Rampart](https://github.com/pcaplan/rampart) framework for Domain-Driven Design and Hexagonal Architecture in a Rails + Next.js monorepo.

## Overview

Cats-as-a-Service is a fictional cat e-commerce platform that demonstrates Rampart patterns in a real-world application. It combines:

- **Rails API** - Backend that mounts bounded context engines
- **Next.js Frontend** - Modern React-based UI
- **Supabase** - PostgreSQL database with migrations
- **Rampart Framework** - DDD/Hexagonal architecture patterns

This application serves as a reference implementation for building Rails applications with clean architecture principles.

## Prerequisites

- Ruby 3.3.6+ (`asdf install ruby 3.3.6`)
- Node.js 18+ (`asdf install nodejs 18.x.x` or via `nvm`)
- Docker Desktop (for Supabase)
- Supabase CLI (`brew install supabase/tap/supabase`)
- Bun (for CLI tools, `brew install bun`)

## Quick Setup

### 1. Start Supabase

```bash
supabase start
```

This creates a local PostgreSQL database and runs migrations automatically.

### 2. Set up Rails API

```bash
cd apps/api
bundle install
```

The API depends on the Rampart framework located at `../../rampart`. Ensure the rampart repository is cloned alongside this repository:

```
/Users/pcaplan/paul/
├── rampart/              # Framework repository
└── cats-as-a-service/    # This repository
```

### 3. Set up Web App

```bash
cd apps/web
npm install
```

### 4. Start Development Servers

From the project root:

```bash
scripts/start_dev.sh
```

This starts:
- Web app on http://localhost:3000
- API on http://localhost:8000

Or start them individually:

```bash
# API only
cd apps/api && rails server

# Web app only
cd apps/web && npm run dev
```

> **Note**: Supabase handles all database schema creation via its migrations. Rails connects to what Supabase created - no Rails migrations needed.

## Project Structure

```
cats-as-a-service/
├── apps/
│   ├── web/                    # Next.js frontend
│   │   ├── app/                 # Next.js app directory
│   │   ├── components/         # React components
│   │   └── package.json
│   │
│   └── api/                     # Rails backend
│       ├── app/
│       ├── config/
│       ├── Gemfile              # References ../../rampart
│       └── ...
│
├── engines/
│   └── cat_content/             # Cat & Content bounded context
│       ├── app/
│       │   ├── domain/          # Pure domain logic
│       │   ├── application/    # Use cases and services
│       │   └── infrastructure/ # Rails adapters
│       ├── lib/
│       ├── cat_content.gemspec
│       └── ...
│
├── architecture/                # Architecture blueprints
│   ├── cat_content.json        # Bounded context definition
│   └── system.json              # System-level architecture
│
├── supabase/                    # Database migrations
│   ├── migrations/
│   └── config.toml
│
├── docs/                        # Application documentation
│   ├── cat_app/                 # Feature specs and guides
│   └── plans/                   # Implementation plans
│
└── scripts/                     # Development scripts
    └── start_dev.sh
```

## Architecture

### Bounded Contexts

Each bounded context is implemented as a Rails Engine:

- **Cat Content** (`engines/cat_content/`) - Catalog of cat listings with filtering and search

Future bounded contexts:
- **Commerce** - Shopping cart, checkout, orders
- **Auth** - User authentication and authorization

### Dependency Flow

```
┌─────────────┐
│   apps/web  │  (Next.js)
└──────┬──────┘
       │ HTTP/JSON
       ▼
┌─────────────┐
│   apps/api  │  (Rails)
└──────┬──────┘
       │ mounts
       ▼
┌──────────────────────────────────────────┐
│            engines/*                     │
│  ┌────────────┐  ┌─────────┐  ┌─────┐   │
│  │cat_content │  │commerce │  │auth │   │
│  └─────┬──────┘  └────┬────┘  └──┬──┘   │
└────────┼─────────────┼──────────┼────────┘
        │            │          │
        └────────────┼──────────┘
                     │ depends on
                     ▼
              ┌─────────────┐
              │ ../rampart  │  (pure Ruby)
              └─────────────┘
```

### Engine Mounting

The main Rails app mounts bounded context engines:

```ruby
# apps/api/config/routes.rb
Rails.application.routes.draw do
  mount CatContent::Engine, at: "/catalog"
  # Future: mount Commerce::Engine, at: "/commerce"
  # Future: mount Auth::Engine, at: "/auth"
end
```

## Documentation

- [Cat Content Implementation](docs/cat_app/cat_content_implementation.md) - Complete implementation guide
- [Cat Content Architecture](docs/cat_app/cat_content_architecture.md) - Bounded context design
- [Cat Content API](docs/cat_app/cat_content_api.md) - API documentation
- [All Bounded Contexts](docs/cat_app/all_bounded_contexts.md) - System overview
- [Requirements](docs/cat_app/requirements.md) - Functional requirements

## Development

### Running Tests

```bash
# Rails API tests
cd apps/api
bundle exec rspec

# Engine tests
cd engines/cat_content
bundle exec rspec
```

### Code Quality

```bash
# RuboCop
cd apps/api
bundle exec rubocop

# TypeScript/ESLint
cd apps/web
npm run lint
```

## Framework Dependency

This application depends on the Rampart framework located at `../rampart`. For local development, ensure both repositories are cloned:

```bash
git clone https://github.com/pcaplan/rampart.git
git clone https://github.com/pcaplan/cats-as-a-service.git
```

The Gemfiles reference the framework using a relative path:

```ruby
gem "rampart", path: "../../rampart"
```

For production deployments or when the framework is published as a gem, update the Gemfiles to use the published version.

## License

This demo application is provided as open source under the terms of the Apache License 2.0.

## Related Projects

- [Rampart Framework](https://github.com/pcaplan/rampart) - DDD/Hexagonal architecture framework for Ruby
