# DevPulse

Real-time developer collaboration platform built with **SvelteKit 2** and **Go/Gin**. Features live code editing with WebSocket-powered cursor presence, threaded discussions with emoji reactions, versioned documentation wiki, and team management.

**Live Demo:** [https://devhub-app-1234.web.app](https://devhub-app-1234.web.app)

![SvelteKit](https://img.shields.io/badge/SvelteKit-2.0-FF3E00?logo=svelte)
![Go](https://img.shields.io/badge/Go-1.22-00ADD8?logo=go)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql)
![TypeScript](https://img.shields.io/badge/TypeScript-5.9-3178C6?logo=typescript)
![Tailwind](https://img.shields.io/badge/Tailwind_CSS-4-06B6D4?logo=tailwindcss)

---

## Features

### Code Rooms (Live Collaboration)
- Real-time code editing with WebSocket connections
- Remote cursor presence with colored indicators and user labels
- Syntax highlighting for Go, TypeScript, Python, Rust, and Swift via CodeMirror 6
- In-room chat with persistent message history
- Participant tracking with join/leave events

### Discussions (Threaded Forum)
- Rich markdown content with code block rendering
- Emoji reactions on discussions and replies (6 emoji types)
- Pin/unpin important discussions
- Tag-based categorization
- Nested reply threads

### Documents (Knowledge Base)
- Markdown editor with live preview
- Full version history with preview and restore
- Hierarchical document organization (parent/child)
- Team-scoped document collections

### Teams & Members
- Team creation with slug-based URLs
- Role-based access control (Owner, Admin, Member, Guest)
- Member invitation and role management
- Per-team rooms, discussions, and documents

### Activity Feed & Notifications
- Global activity feed across all teams
- Filterable by type (Rooms, Discussions, Docs, Teams)
- Real-time notification dropdown with unread indicators
- Click-to-navigate notification links

---

## Tech Stack

### Frontend
| Technology | Purpose |
|-----------|---------|
| [SvelteKit 2](https://kit.svelte.dev/) | Full-stack framework with file-based routing |
| [Svelte 5](https://svelte.dev/) | Reactive UI with runes (`$state`, `$derived`, `$effect`) |
| [TypeScript 5.9](https://www.typescriptlang.org/) | Type safety |
| [Tailwind CSS 4](https://tailwindcss.com/) | Utility-first styling |
| [Skeleton UI v3](https://skeleton.dev/) | Component library (Cerberus theme) |
| [CodeMirror 6](https://codemirror.net/) | Code editor with language support |
| [Marked](https://marked.js.org/) | Markdown rendering |

### Backend
| Technology | Purpose |
|-----------|---------|
| [Go 1.22](https://go.dev/) | API server |
| [Gin](https://gin-gonic.com/) | HTTP framework |
| [gorilla/websocket](https://github.com/gorilla/websocket) | WebSocket connections |
| [pgx v5](https://github.com/jackc/pgx) | PostgreSQL driver |
| [sqlc](https://sqlc.dev/) | Type-safe SQL code generation |
| [golang-migrate](https://github.com/golang-migrate/migrate) | Database migrations |
| [zerolog](https://github.com/rs/zerolog) | Structured logging |
| [Prometheus](https://prometheus.io/) | Metrics collection |

### Infrastructure
| Technology | Purpose |
|-----------|---------|
| [PostgreSQL 16](https://www.postgresql.org/) | Primary database |
| [Redis 7](https://redis.io/) | Pub/sub & caching (optional) |
| [Docker Compose](https://docs.docker.com/compose/) | Local development |
| [Kubernetes](https://kubernetes.io/) | Production orchestration |
| [Firebase Hosting](https://firebase.google.com/products/hosting) | Frontend static hosting |
| [Google Cloud Run](https://cloud.google.com/run) | Backend container hosting |
| [Neon](https://neon.tech/) | Managed PostgreSQL (production) |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Firebase Hosting                          │
│                  (Static SvelteKit SPA)                      │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTPS
┌──────────────────────▼──────────────────────────────────────┐
│                   Google Cloud Run                           │
│               ┌─────────────────────┐                        │
│               │    Go/Gin API       │                        │
│               │  ┌───────────────┐  │                        │
│               │  │  HTTP Routes  │  │                        │
│               │  │  WebSocket    │  │                        │
│               │  │  Auth MW      │  │                        │
│               │  │  CORS MW      │  │                        │
│               │  └───────────────┘  │                        │
│               └─────────┬───────────┘                        │
└─────────────────────────┼────────────────────────────────────┘
                          │
          ┌───────────────┴───────────────┐
          ▼                               ▼
┌──────────────────┐           ┌──────────────────┐
│  Neon PostgreSQL │           │  Redis (optional) │
│  - Users         │           │  - Pub/Sub        │
│  - Teams         │           │  - Activity cache │
│  - Rooms         │           └──────────────────┘
│  - Discussions   │
│  - Documents     │
│  - Activities    │
│  - Notifications │
└──────────────────┘
```

---

## Project Structure

```
devpulse/
├── frontend/                    # SvelteKit 2 application
│   ├── src/
│   │   ├── routes/              # 11 pages (file-based routing)
│   │   │   ├── +page.svelte     # Dashboard with activity feed
│   │   │   ├── login/           # Demo user authentication
│   │   │   ├── rooms/           # Code collaboration rooms
│   │   │   ├── discussions/     # Threaded discussions
│   │   │   ├── docs/            # Documentation wiki
│   │   │   ├── teams/           # Team management
│   │   │   └── settings/        # User preferences
│   │   ├── lib/
│   │   │   ├── stores/          # 6 Svelte stores (auth, rooms, etc.)
│   │   │   ├── services/        # API client & WebSocket service
│   │   │   ├── components/      # Shared UI components
│   │   │   │   ├── shared/      # Badge, Modal, EmptyState, etc.
│   │   │   │   ├── layout/      # Header, Sidebar
│   │   │   │   └── editor/      # CodeMirror integration
│   │   │   └── utils/           # Formatting & markdown helpers
│   │   └── app.css              # Global styles & CSS variables
│   ├── svelte.config.js         # adapter-static with SPA fallback
│   └── package.json
│
├── backend/                     # Go 1.22 API server
│   ├── cmd/server/              # Application entry point
│   ├── internal/
│   │   ├── handler/             # HTTP & WebSocket handlers
│   │   ├── repository/          # Database queries (sqlc)
│   │   ├── service/             # Business logic layer
│   │   ├── middleware/          # Auth, CORS, metrics
│   │   └── config/              # Environment configuration
│   ├── database/
│   │   ├── migrations/          # SQL schema migrations
│   │   ├── queries/             # sqlc query definitions
│   │   ├── seed.sql             # Demo seed data (62KB)
│   │   └── seed-neon.sql        # Neon-compatible seed
│   ├── deployments/
│   │   ├── docker/Dockerfile    # Multi-stage Go build
│   │   └── k8s/                 # Kubernetes manifests
│   ├── monitoring/              # Prometheus & Grafana configs
│   └── go.mod
│
├── docker-compose.yml           # Local dev environment
├── firebase.json                # Firebase Hosting config
├── .github/workflows/ci.yml     # CI/CD pipeline
└── README.md
```

---

## Getting Started

### Prerequisites

- [Node.js 22+](https://nodejs.org/)
- [Go 1.22+](https://go.dev/) (for backend development)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (for local infrastructure)

### Local Development

**1. Start infrastructure:**

```bash
docker compose up -d postgres redis
```

**2. Run database migrations and seed data:**

```bash
# Apply schema
psql -h localhost -p 5433 -U devpulse -d devpulse -f backend/database/migrations/001_initial_schema.up.sql

# Seed demo data
psql -h localhost -p 5433 -U devpulse -d devpulse -f backend/database/seed.sql
```

**3. Start the Go API server:**

```bash
cd backend
go run cmd/server/main.go
# API runs on http://localhost:8080
```

**4. Start the frontend:**

```bash
cd frontend
npm install
npm run dev
# App runs on http://localhost:5173
```

**5. Open the app** and log in with one of the demo users (Alex Rivera, Sam Chen, or Jordan Park).

### Docker Compose (Full Stack)

```bash
# Start everything
docker compose up -d

# With monitoring (Prometheus + Grafana)
docker compose up -d --profile monitoring

# View logs
docker compose logs -f api
```

| Service | Port | Purpose |
|---------|------|---------|
| Frontend | 5173 | SvelteKit dev server |
| API | 8080 | Go/Gin backend |
| PostgreSQL | 5433 | Database |
| Redis | 6380 | Pub/sub (optional) |
| Prometheus | 9090 | Metrics (monitoring profile) |
| Grafana | 3200 | Dashboards (monitoring profile) |

---

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user |
| GET | `/api/auth/me` | Get current user profile |

### Teams
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/teams` | List user's teams |
| POST | `/api/teams` | Create team |
| GET | `/api/teams/:id` | Get team details |
| POST | `/api/teams/:id/members` | Add member |
| PUT | `/api/teams/:id/members/:uid` | Update member role |
| DELETE | `/api/teams/:id/members/:uid` | Remove member |

### Rooms
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/teams/:teamId/rooms` | List rooms |
| POST | `/api/teams/:teamId/rooms` | Create room |
| GET | `/api/rooms/:id` | Get room details |
| WS | `/ws/room/:id` | WebSocket connection |

### Discussions
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/teams/:teamId/discussions` | List discussions |
| POST | `/api/teams/:teamId/discussions` | Create discussion |
| GET | `/api/discussions/:id` | Get discussion with replies |
| POST | `/api/discussions/:id/replies` | Add reply |
| POST | `/api/discussions/:id/reactions` | Toggle reaction |
| PUT | `/api/discussions/:id/pin` | Toggle pin |

### Documents
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/teams/:teamId/docs` | List documents |
| POST | `/api/teams/:teamId/docs` | Create document |
| GET | `/api/docs/:id` | Get document |
| PUT | `/api/docs/:id` | Update document |
| GET | `/api/docs/:id/versions` | Get version history |
| POST | `/api/docs/:id/versions` | Create version |

### System
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/activities` | Activity feed |
| GET | `/api/notifications` | User notifications |
| PUT | `/api/notifications/:id/read` | Mark as read |

**Authentication:** All endpoints (except health) require `Authorization: Bearer <token>` header. In demo mode, use `dev:<firebase_uid>` (e.g., `dev:demo-alex`).

---

## Database Schema

```
users ──────────── team_members ──────── teams
  │                                        │
  ├── rooms ────── room_participants       ├── projects
  │       └── room_messages                │
  │                                        ├── discussions
  ├── activities                           │      ├── discussion_replies
  │                                        │      └── reactions
  ├── notifications                        │
  │                                        └── documents
  └── reactions                                   └── document_versions
```

8 users, 3 teams, 5 projects, 3 rooms, 10 discussions, 8 documents included in seed data.

---

## Deployment

### Production Stack
- **Frontend:** Firebase Hosting (static SPA)
- **Backend:** Google Cloud Run (Docker container)
- **Database:** Neon (managed PostgreSQL)
- **CI/CD:** GitHub Actions

### Environment Variables

**Cloud Run (Backend):**
| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis URL (empty to disable) |
| `ENVIRONMENT` | `production` or `development` |
| `CORS_ORIGINS` | Allowed origins (comma-separated) |

**Frontend Build:**
| Variable | Description |
|----------|-------------|
| `VITE_API_URL` | Backend API base URL |

### CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/ci.yml`) runs on push to `main`:

1. **Backend** - `go mod tidy` + `go build` + `go test`
2. **Frontend** - `npm ci` + `npm run build`
3. **Deploy** (on push to main only):
   - Build Docker image and push to Artifact Registry
   - Deploy to Cloud Run with env vars
   - Build frontend with `VITE_API_URL` and deploy to Firebase Hosting

### Kubernetes (Alternative)

K8s manifests are in `backend/deployments/k8s/`:
- **Deployment:** 2 replicas, health checks, resource limits
- **HPA:** Auto-scales 2-10 pods based on CPU/memory
- **Ingress:** NGINX with TLS (cert-manager) and WebSocket support

---

## Monitoring

Optional Prometheus + Grafana stack available via Docker Compose:

```bash
docker compose up -d --profile monitoring
```

- **Prometheus** (`:9090`) - Scrapes `/api/metrics` from the Go API
- **Grafana** (`:3200`) - Pre-configured dashboards for:
  - Request rate, latency percentiles, error rates
  - Database query performance
  - WebSocket connection counts
  - Pod resource utilization

---

## Demo Accounts

| User | Email | Role |
|------|-------|------|
| Alex Rivera | alex@devpulse.dev | Full-stack developer |
| Sam Chen | sam@devpulse.dev | Backend engineer |
| Jordan Park | jordan@devpulse.dev | DevOps lead |

Log in from the login page to explore the platform with pre-seeded data.

---

## License

MIT
