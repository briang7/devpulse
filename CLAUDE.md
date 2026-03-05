# DevPulse - Real-time Developer Collaboration Platform

## Overview
Portfolio Project #3 for WebVista. Real-time developer collaboration platform showcasing Go backend (concurrency, WebSockets) + SvelteKit frontend (compile-time reactivity).

## Project Structure
- `frontend/` — SvelteKit 2 app (Node.js)
- `backend/` — Go 1.22 + Gin (runs in Docker)

## Tech Stack
- **Frontend:** SvelteKit 2, Svelte 5, Skeleton UI v3, Tailwind CSS 4, TypeScript
- **Backend:** Go 1.22, Gin, PostgreSQL 16, Redis 7, WebSocket (gorilla/websocket)
- **Auth:** Firebase Auth (consistent with WebVista ecosystem)
- **Real-time:** Yjs (CRDT) on frontend, Go WebSocket hub as relay/persistence
- **Infrastructure:** Docker Compose, Kubernetes manifests, Prometheus, Grafana

## Ports
| Service | Port |
|---------|------|
| SvelteKit dev | 5173 |
| Go API + WebSocket | 8080 |
| PostgreSQL | 5433 |
| Redis | 6380 |
| Prometheus | 9090 |
| Grafana | 3200 |

## Commands

### Frontend
```bash
cd frontend
npm run dev          # Start dev server on :5173
npm run build        # Build for production
npm run check        # Type-check Svelte
```

### Backend (Docker)
```bash
docker compose up -d                    # Start all services
docker compose up -d postgres redis     # Start only DB + cache
docker compose logs -f api              # View API logs
```

### Database
```bash
# Migrations run automatically on postgres container start
# (mounted from backend/database/migrations/)
```

## Architecture Notes
- Go backend runs ONLY in Docker (no local Go installation required)
- Vite dev server proxies /api/* to localhost:8080 and /ws/* to ws://localhost:8080
- Firebase Auth tokens validated in Go middleware (dev mode accepts "dev:<uid>" tokens)
- Yjs binary updates relayed through Go WebSocket hub, persisted to PostgreSQL
- Activity feed uses Redis pub/sub for real-time updates
