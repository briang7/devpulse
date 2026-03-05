package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	ctx := context.Background()

	pool, err := pgxpool.New(ctx, "postgres://devpulse:devpulse@localhost:5433/devpulse?sslmode=disable")
	if err != nil {
		log.Fatal("Failed to connect:", err)
	}
	defer pool.Close()

	fmt.Println("Seeding DevPulse database...")

	// Users
	users := []struct {
		id          string
		firebaseUID string
		email       string
		displayName string
		status      string
		bio         string
	}{
		{"00000000-0000-0000-0000-000000000001", "demo-alex", "alex@devpulse.dev", "Alex Rivera", "online", "Full-stack developer. Rust enthusiast."},
		{"00000000-0000-0000-0000-000000000002", "demo-sam", "sam@devpulse.dev", "Sam Chen", "online", "Backend engineer. Go & Kubernetes."},
		{"00000000-0000-0000-0000-000000000003", "demo-jordan", "jordan@devpulse.dev", "Jordan Park", "away", "DevOps lead. Infrastructure as code."},
		{"00000000-0000-0000-0000-000000000004", "demo-casey", "casey@devpulse.dev", "Casey Morgan", "online", "Frontend specialist. Svelte & React."},
		{"00000000-0000-0000-0000-000000000005", "demo-taylor", "taylor@devpulse.dev", "Taylor Kim", "offline", "Data engineer. Python & SQL."},
		{"00000000-0000-0000-0000-000000000006", "demo-riley", "riley@devpulse.dev", "Riley Zhang", "online", "Mobile developer. Swift & Kotlin."},
		{"00000000-0000-0000-0000-000000000007", "demo-avery", "avery@devpulse.dev", "Avery Patel", "away", "Security engineer. Penetration testing."},
		{"00000000-0000-0000-0000-000000000008", "demo-quinn", "quinn@devpulse.dev", "Quinn Silva", "online", "ML engineer. PyTorch & TensorFlow."},
	}

	for _, u := range users {
		_, err := pool.Exec(ctx,
			`INSERT INTO users (id, firebase_uid, email, display_name, status, bio) VALUES ($1, $2, $3, $4, $5, $6) ON CONFLICT (firebase_uid) DO NOTHING`,
			u.id, u.firebaseUID, u.email, u.displayName, u.status, u.bio)
		if err != nil {
			log.Printf("User %s: %v", u.displayName, err)
		}
	}
	fmt.Println("  ✓ 8 users created")

	// Teams
	teams := []struct {
		id          string
		name        string
		slug        string
		description string
		createdBy   string
	}{
		{"10000000-0000-0000-0000-000000000001", "Frontend Guild", "frontend-guild", "UI/UX and frontend architecture discussions", users[0].id},
		{"10000000-0000-0000-0000-000000000002", "Backend Crew", "backend-crew", "APIs, databases, and server-side engineering", users[1].id},
		{"10000000-0000-0000-0000-000000000003", "DevOps Squad", "devops-squad", "CI/CD, infrastructure, and deployment automation", users[2].id},
	}

	for _, t := range teams {
		_, err := pool.Exec(ctx,
			`INSERT INTO teams (id, name, slug, description, created_by) VALUES ($1, $2, $3, $4, $5) ON CONFLICT (slug) DO NOTHING`,
			t.id, t.name, t.slug, t.description, t.createdBy)
		if err != nil {
			log.Printf("Team %s: %v", t.name, err)
		}
	}
	fmt.Println("  ✓ 3 teams created")

	// Team members
	members := []struct {
		teamID string
		userID string
		role   string
	}{
		// Frontend Guild
		{teams[0].id, users[0].id, "owner"},
		{teams[0].id, users[3].id, "admin"},
		{teams[0].id, users[5].id, "member"},
		{teams[0].id, users[7].id, "member"},
		// Backend Crew
		{teams[1].id, users[1].id, "owner"},
		{teams[1].id, users[0].id, "member"},
		{teams[1].id, users[4].id, "admin"},
		{teams[1].id, users[6].id, "member"},
		// DevOps Squad
		{teams[2].id, users[2].id, "owner"},
		{teams[2].id, users[1].id, "member"},
		{teams[2].id, users[6].id, "admin"},
		{teams[2].id, users[3].id, "guest"},
	}

	for _, m := range members {
		pool.Exec(ctx,
			`INSERT INTO team_members (team_id, user_id, role) VALUES ($1, $2, $3) ON CONFLICT (team_id, user_id) DO NOTHING`,
			m.teamID, m.userID, m.role)
	}
	fmt.Println("  ✓ 12 team memberships created")

	// Projects
	projectIDs := []string{
		"20000000-0000-0000-0000-000000000001",
		"20000000-0000-0000-0000-000000000002",
		"20000000-0000-0000-0000-000000000003",
		"20000000-0000-0000-0000-000000000004",
		"20000000-0000-0000-0000-000000000005",
	}

	projectData := []struct {
		id          string
		teamID      string
		name        string
		description string
		language    string
		createdBy   string
	}{
		{projectIDs[0], teams[0].id, "Component Library", "Shared UI component library built with Svelte", "TypeScript", users[0].id},
		{projectIDs[1], teams[0].id, "Design System", "Brand guidelines and design tokens", "CSS", users[3].id},
		{projectIDs[2], teams[1].id, "API Gateway", "Central API gateway with rate limiting", "Go", users[1].id},
		{projectIDs[3], teams[1].id, "Auth Service", "Authentication and authorization microservice", "Go", users[1].id},
		{projectIDs[4], teams[2].id, "Infrastructure", "Terraform configs and Kubernetes manifests", "YAML", users[2].id},
	}

	for _, p := range projectData {
		pool.Exec(ctx,
			`INSERT INTO projects (id, team_id, name, description, language, created_by) VALUES ($1, $2, $3, $4, $5, $6) ON CONFLICT DO NOTHING`,
			p.id, p.teamID, p.name, p.description, p.language, p.createdBy)
	}
	fmt.Println("  ✓ 5 projects created")

	// Rooms
	roomIDs := []string{
		"30000000-0000-0000-0000-000000000001",
		"30000000-0000-0000-0000-000000000002",
		"30000000-0000-0000-0000-000000000003",
	}

	roomData := []struct {
		id        string
		name      string
		desc      string
		language  string
		teamID    string
		createdBy string
	}{
		{roomIDs[0], "Svelte Reactivity Deep Dive", "Exploring Svelte 5 runes and fine-grained reactivity", "TypeScript", teams[0].id, users[0].id},
		{roomIDs[1], "Go Concurrency Patterns", "Building robust concurrent systems with goroutines and channels", "Go", teams[1].id, users[1].id},
		{roomIDs[2], "Kubernetes Operators", "Custom controller development with kubebuilder", "Go", teams[2].id, users[2].id},
	}

	for _, r := range roomData {
		pool.Exec(ctx,
			`INSERT INTO rooms (id, name, description, language, team_id, created_by, is_active) VALUES ($1, $2, $3, $4, $5, $6, true) ON CONFLICT DO NOTHING`,
			r.id, r.name, r.desc, r.language, r.teamID, r.createdBy)
	}
	fmt.Println("  ✓ 3 code rooms created")

	// Discussions
	discussions := []struct {
		id       string
		teamID   string
		title    string
		content  string
		authorID string
		isPinned bool
		tags     string
	}{
		{
			"40000000-0000-0000-0000-000000000001", teams[0].id,
			"RFC: Migrating to Svelte 5 Runes",
			"I've been testing the new runes API and I think we should start migrating our components.\n\n## Benefits\n- Fine-grained reactivity\n- Better TypeScript support\n- Smaller bundle size\n\n## Migration Strategy\n1. Start with leaf components\n2. Move to shared stores\n3. Update page components last\n\nWhat does everyone think? Any concerns about the timeline?",
			users[0].id, true, "{svelte,rfc,migration}",
		},
		{
			"40000000-0000-0000-0000-000000000002", teams[0].id,
			"Best practices for accessible forms",
			"Let's document our form accessibility standards.\n\n```html\n<label for=\"email\">Email</label>\n<input id=\"email\" type=\"email\" aria-describedby=\"email-help\" />\n<p id=\"email-help\">We'll never share your email.</p>\n```\n\nKey points:\n- Always use labels\n- Provide error descriptions\n- Support keyboard navigation",
			users[3].id, false, "{accessibility,forms,best-practices}",
		},
		{
			"40000000-0000-0000-0000-000000000003", teams[1].id,
			"Database connection pooling strategies",
			"We're hitting connection limits under load. Here are three approaches:\n\n1. **pgbouncer** - External connection pooler\n2. **pgx pool** - Built-in Go connection pool\n3. **PgBouncer + pgx** - Belt and suspenders\n\nOur current setup uses pgx with max 20 connections. Under 500 req/s we're fine, but spikes to 2000 req/s cause timeouts.\n\nShould we add pgbouncer or increase the pool size?",
			users[1].id, true, "{database,performance,postgresql}",
		},
		{
			"40000000-0000-0000-0000-000000000004", teams[1].id,
			"Error handling patterns in Go",
			"I've been reading about different error handling approaches:\n\n```go\n// Sentinel errors\nvar ErrNotFound = errors.New(\"not found\")\n\n// Custom error types\ntype ValidationError struct {\n    Field   string\n    Message string\n}\n\n// Error wrapping\nfmt.Errorf(\"user %s: %w\", id, err)\n```\n\nWhich pattern should we standardize on for our services?",
			users[4].id, false, "{go,error-handling,patterns}",
		},
		{
			"40000000-0000-0000-0000-000000000005", teams[2].id,
			"Helm vs Kustomize for K8s deployments",
			"We need to decide on a templating strategy for our Kubernetes manifests.\n\n**Helm Pros:** Package management, huge ecosystem, chart repos\n**Helm Cons:** Complex templating, security concerns with Tiller (old)\n\n**Kustomize Pros:** Built into kubectl, overlay-based, no templating\n**Kustomize Cons:** Limited logic, no packaging\n\nI'm leaning toward Kustomize for simplicity. Thoughts?",
			users[2].id, false, "{kubernetes,helm,kustomize,devops}",
		},
		{
			"40000000-0000-0000-0000-000000000006", teams[0].id,
			"CSS-in-JS vs Tailwind CSS for component library",
			"As we build out the component library, we need to finalize our styling approach.\n\nOptions:\n1. **Tailwind CSS** - Utility-first, great DX, but verbose\n2. **Vanilla Extract** - Zero-runtime CSS-in-TS\n3. **CSS Modules** - Scoped CSS, simple\n\nI've built prototypes with each. Tailwind gives us the fastest iteration speed.",
			users[3].id, false, "{css,tailwind,design-system}",
		},
		{
			"40000000-0000-0000-0000-000000000007", teams[1].id,
			"WebSocket vs SSE for real-time updates",
			"For our activity feed, we have two options:\n\n**WebSocket:** Bidirectional, good for chat. More complex.\n**SSE:** Server-to-client only, simpler, auto-reconnect.\n\nSince the activity feed is read-only from the client's perspective, SSE might be simpler. But we already have WebSocket infrastructure for code rooms.\n\nShould we reuse WebSocket or add SSE?",
			users[1].id, false, "{websocket,sse,real-time,architecture}",
		},
		{
			"40000000-0000-0000-0000-000000000008", teams[2].id,
			"Monitoring stack: Prometheus + Grafana setup",
			"I've set up the initial monitoring stack:\n\n- Prometheus scraping Go API metrics at `/api/metrics`\n- Grafana dashboards for API latency, throughput, WebSocket connections\n- AlertManager for on-call notifications\n\nNext steps:\n- [ ] Add PostgreSQL exporter\n- [ ] Set up log aggregation (Loki?)\n- [ ] Create runbooks for common alerts\n\nWho wants to help with the PostgreSQL metrics?",
			users[2].id, true, "{monitoring,prometheus,grafana,devops}",
		},
		{
			"40000000-0000-0000-0000-000000000009", teams[0].id,
			"Code review checklist proposal",
			"I'd like to propose a standard code review checklist:\n\n- [ ] Types are correct and complete\n- [ ] No unnecessary re-renders\n- [ ] Accessibility reviewed\n- [ ] Error states handled\n- [ ] Loading states present\n- [ ] Mobile responsive\n- [ ] Tests added/updated\n\nShould we enforce this via PR template?",
			users[0].id, false, "{process,code-review,quality}",
		},
		{
			"40000000-0000-0000-0000-000000000010", teams[1].id,
			"API versioning strategy",
			"As we prepare for v2 of the API, we need a versioning strategy:\n\n1. **URL path:** `/api/v1/users` → `/api/v2/users`\n2. **Header:** `Accept: application/vnd.devpulse.v2+json`\n3. **Query param:** `/api/users?version=2`\n\nURL path is the most common and easiest to understand. Header-based is more \"correct\" per REST principles.\n\nI recommend URL path for simplicity.",
			users[4].id, false, "{api,versioning,architecture}",
		},
	}

	for _, d := range discussions {
		pool.Exec(ctx,
			`INSERT INTO discussions (id, team_id, title, content, author_id, is_pinned, tags, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) ON CONFLICT DO NOTHING`,
			d.id, d.teamID, d.title, d.content, d.authorID, d.isPinned, d.tags, time.Now().Add(-time.Duration(len(discussions))*time.Hour))
	}
	fmt.Println("  ✓ 10 discussions created")

	// Discussion replies
	replies := []struct {
		discussionID string
		authorID     string
		content      string
	}{
		{discussions[0].id, users[3].id, "Love this proposal! The runes API is so much cleaner. I've already converted the Button and Input components as a proof of concept."},
		{discussions[0].id, users[5].id, "+1 on starting with leaf components. I can take on the Icon and Badge components this sprint."},
		{discussions[0].id, users[0].id, "Great initiative from both of you! Let's create a tracking issue and assign components to team members."},
		{discussions[2].id, users[4].id, "pgbouncer has been solid in my experience. We used it at my last company handling 10k req/s. The session pooling mode works great with pgx."},
		{discussions[2].id, users[6].id, "From a security perspective, pgbouncer also helps with connection auditing. I'd recommend it."},
		{discussions[4].id, users[6].id, "Kustomize is great for simple overlays. But once you need to template 20+ services, Helm charts save a lot of duplication."},
		{discussions[4].id, users[2].id, "Fair point. Maybe we use Kustomize for our own services and Helm for third-party dependencies?"},
		{discussions[7].id, users[1].id, "I can help with the PostgreSQL exporter. I've set it up before — it's just a Docker container with the connection string."},
		{discussions[7].id, users[6].id, "For log aggregation, I'd recommend Loki over ELK. Much simpler to operate and integrates natively with Grafana."},
	}

	for _, r := range replies {
		pool.Exec(ctx,
			`INSERT INTO discussion_replies (id, discussion_id, author_id, content) VALUES ($1, $2, $3, $4)`,
			uuid.New().String(), r.discussionID, r.authorID, r.content)
	}
	fmt.Println("  ✓ 9 discussion replies created")

	// Reactions
	emojis := []string{"👍", "❤️", "🔥", "💡", "🎉", "👀"}
	reactionCount := 0
	for i, d := range discussions {
		for j := 0; j < (i%3)+1; j++ {
			userIdx := (i + j) % len(users)
			emojiIdx := (i + j) % len(emojis)
			pool.Exec(ctx,
				`INSERT INTO reactions (id, target_type, target_id, user_id, emoji) VALUES ($1, 'discussion', $2, $3, $4) ON CONFLICT DO NOTHING`,
				uuid.New().String(), d.id, users[userIdx].id, emojis[emojiIdx])
			reactionCount++
		}
	}
	fmt.Printf("  ✓ %d reactions created\n", reactionCount)

	// Documents
	docIDs := []string{
		"50000000-0000-0000-0000-000000000001",
		"50000000-0000-0000-0000-000000000002",
		"50000000-0000-0000-0000-000000000003",
		"50000000-0000-0000-0000-000000000004",
		"50000000-0000-0000-0000-000000000005",
		"50000000-0000-0000-0000-000000000006",
		"50000000-0000-0000-0000-000000000007",
		"50000000-0000-0000-0000-000000000008",
	}

	docs := []struct {
		id       string
		teamID   string
		parentID *string
		title    string
		slug     string
		content  string
		authorID string
		order    int
	}{
		{docIDs[0], teams[0].id, nil, "Getting Started", "getting-started",
			"# Getting Started\n\nWelcome to the Frontend Guild! This guide will help you set up your development environment.\n\n## Prerequisites\n- Node.js 22+\n- pnpm 9+\n- VS Code with Svelte extension\n\n## Quick Start\n```bash\ngit clone <repo>\npnpm install\npnpm dev\n```\n\n## Project Structure\n- `src/lib/components/` — Shared components\n- `src/lib/stores/` — Svelte stores\n- `src/routes/` — Page routes\n",
			users[0].id, 0},
		{docIDs[1], teams[0].id, nil, "Architecture", "architecture",
			"# Architecture Overview\n\n## Tech Stack\n- **SvelteKit 2** — Full-stack framework\n- **Tailwind CSS 4** — Utility-first styling\n- **TypeScript** — Type safety\n\n## Data Flow\n1. User action triggers store update\n2. Store calls API service\n3. API service makes HTTP request\n4. Response updates store\n5. Reactive UI updates automatically\n",
			users[3].id, 1},
		{docIDs[2], teams[0].id, &docIDs[1], "Component Guidelines", "component-guidelines",
			"# Component Guidelines\n\n## Naming Convention\n- PascalCase for component files\n- camelCase for props\n- kebab-case for CSS classes\n\n## Prop Types\nAlways define TypeScript interfaces for component props.\n\n```svelte\n<script lang=\"ts\">\n  let { name = '', size = 'md' as 'sm' | 'md' | 'lg' } = $props();\n</script>\n```\n",
			users[0].id, 0},
		{docIDs[3], teams[0].id, &docIDs[1], "State Management", "state-management",
			"# State Management\n\n## Svelte Stores\nWe use Svelte's built-in stores for global state.\n\n```ts\nimport { writable, derived } from 'svelte/store';\n\nexport const count = writable(0);\nexport const doubled = derived(count, $c => $c * 2);\n```\n\n## Guidelines\n- One store per domain (auth, teams, rooms)\n- Async operations in store functions\n- Optimistic updates for better UX\n",
			users[3].id, 1},
		{docIDs[4], teams[1].id, nil, "API Reference", "api-reference",
			"# API Reference\n\nBase URL: `http://localhost:8080/api`\n\n## Authentication\nAll requests require a Bearer token in the Authorization header.\n\n## Endpoints\n\n### Teams\n- `GET /teams` — List user's teams\n- `POST /teams` — Create team\n- `GET /teams/:id` — Get team details\n\n### Rooms\n- `GET /rooms` — List rooms\n- `POST /rooms` — Create room\n- `GET /rooms/:id` — Get room\n",
			users[1].id, 0},
		{docIDs[5], teams[1].id, nil, "Database Schema", "database-schema",
			"# Database Schema\n\nPostgreSQL 16 with UUID primary keys.\n\n## Core Tables\n- `users` — User profiles (Firebase UID)\n- `teams` — Team organizations\n- `team_members` — Team membership with roles\n- `projects` — Team projects\n\n## Feature Tables\n- `rooms` — Live code collaboration rooms\n- `discussions` — Threaded discussions\n- `documents` — Wiki documentation\n- `activities` — Activity feed\n",
			users[4].id, 1},
		{docIDs[6], teams[2].id, nil, "Deployment Guide", "deployment-guide",
			"# Deployment Guide\n\n## Docker Compose (Development)\n```bash\ndocker compose up -d\n```\n\n## Kubernetes (Production)\n```bash\nkubectl apply -f deployments/k8s/\n```\n\n## Environment Variables\n| Variable | Description | Default |\n|----------|-------------|---------|\n| PORT | API port | 8080 |\n| DATABASE_URL | PostgreSQL connection | localhost:5433 |\n| REDIS_URL | Redis connection | localhost:6380 |\n",
			users[2].id, 0},
		{docIDs[7], teams[2].id, nil, "Monitoring Runbook", "monitoring-runbook",
			"# Monitoring Runbook\n\n## Dashboards\n- **API Overview** — Request rate, latency, error rate\n- **WebSocket** — Active connections, message throughput\n- **Database** — Query performance, connection pool\n\n## Common Alerts\n\n### High Latency (p95 > 500ms)\n1. Check database query performance\n2. Check Redis connection\n3. Scale up if CPU > 70%\n\n### WebSocket Disconnections\n1. Check Go API logs for errors\n2. Verify Redis pub/sub is healthy\n",
			users[2].id, 1},
	}

	for _, d := range docs {
		pool.Exec(ctx,
			`INSERT INTO documents (id, team_id, parent_id, title, slug, content, author_id, sort_order) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) ON CONFLICT DO NOTHING`,
			d.id, d.teamID, d.parentID, d.title, d.slug, d.content, d.authorID, d.order)
	}
	fmt.Println("  ✓ 8 documents created")

	// Activities
	activityData := []struct {
		teamID     string
		actorID    string
		action     string
		targetType string
		targetID   string
		targetName string
	}{
		{teams[0].id, users[0].id, "created", "room", roomIDs[0], "Svelte Reactivity Deep Dive"},
		{teams[1].id, users[1].id, "created", "room", roomIDs[1], "Go Concurrency Patterns"},
		{teams[2].id, users[2].id, "created", "room", roomIDs[2], "Kubernetes Operators"},
		{teams[0].id, users[0].id, "posted", "discussion", discussions[0].id, "RFC: Migrating to Svelte 5 Runes"},
		{teams[0].id, users[3].id, "replied", "discussion", discussions[0].id, "RFC: Migrating to Svelte 5 Runes"},
		{teams[1].id, users[1].id, "posted", "discussion", discussions[2].id, "Database connection pooling strategies"},
		{teams[0].id, users[3].id, "created", "document", docIDs[1], "Architecture"},
		{teams[1].id, users[1].id, "created", "document", docIDs[4], "API Reference"},
		{teams[2].id, users[2].id, "created", "document", docIDs[6], "Deployment Guide"},
		{teams[0].id, users[5].id, "joined", "team", teams[0].id, "Frontend Guild"},
		{teams[1].id, users[6].id, "joined", "team", teams[1].id, "Backend Crew"},
		{teams[0].id, users[0].id, "created", "project", projectIDs[0], "Component Library"},
		{teams[1].id, users[1].id, "created", "project", projectIDs[2], "API Gateway"},
		{teams[2].id, users[2].id, "posted", "discussion", discussions[7].id, "Monitoring stack: Prometheus + Grafana setup"},
		{teams[0].id, users[3].id, "posted", "discussion", discussions[5].id, "CSS-in-JS vs Tailwind CSS for component library"},
	}

	for i, a := range activityData {
		pool.Exec(ctx,
			`INSERT INTO activities (id, team_id, actor_id, action, target_type, target_id, target_name, metadata, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7, '{}', $8)`,
			uuid.New().String(), a.teamID, a.actorID, a.action, a.targetType, a.targetID, a.targetName,
			time.Now().Add(-time.Duration(len(activityData)-i)*30*time.Minute))
	}
	fmt.Printf("  ✓ %d activities created\n", len(activityData))

	fmt.Println("\nDone! Database seeded successfully.")
}
