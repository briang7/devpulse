-- =============================================================================
-- DevPulse Seed Data (Neon-compatible)
-- =============================================================================
-- No transaction wrapper - each INSERT commits independently.
-- Uses dollar-quoting to avoid E-string escape issues.
-- =============================================================================

-- 1. USERS
INSERT INTO users (id, firebase_uid, email, display_name, avatar_url, status, bio, created_at, updated_at) VALUES
  ('00000000-0000-0000-0000-000000000001', 'demo-alex',   'alex@devpulse.dev',   'Alex Rivera',  '', 'online',  'Full-stack developer. Rust enthusiast.',         NOW() - INTERVAL '90 days', NOW() - INTERVAL '1 hour'),
  ('00000000-0000-0000-0000-000000000002', 'demo-sam',    'sam@devpulse.dev',    'Sam Chen',     '', 'online',  'Backend engineer. Go & Kubernetes.',              NOW() - INTERVAL '88 days', NOW() - INTERVAL '2 hours'),
  ('00000000-0000-0000-0000-000000000003', 'demo-jordan', 'jordan@devpulse.dev', 'Jordan Park',  '', 'away',    'DevOps lead. Infrastructure as code.',            NOW() - INTERVAL '87 days', NOW() - INTERVAL '30 minutes'),
  ('00000000-0000-0000-0000-000000000004', 'demo-morgan', 'morgan@devpulse.dev', 'Morgan Lee',   '', 'online',  'Frontend engineer. React & Svelte.',              NOW() - INTERVAL '75 days', NOW() - INTERVAL '3 hours'),
  ('00000000-0000-0000-0000-000000000005', 'demo-casey',  'casey@devpulse.dev',  'Casey Taylor',  '', 'offline', 'Data engineer. Python & Spark.',                 NOW() - INTERVAL '70 days', NOW() - INTERVAL '1 day'),
  ('00000000-0000-0000-0000-000000000006', 'demo-riley',  'riley@devpulse.dev',  'Riley Quinn',   '', 'online',  'Security engineer. Penetration testing.',        NOW() - INTERVAL '60 days', NOW() - INTERVAL '45 minutes'),
  ('00000000-0000-0000-0000-000000000007', 'demo-avery',  'avery@devpulse.dev',  'Avery Kim',     '', 'away',    'Mobile dev. Flutter & Swift.',                   NOW() - INTERVAL '55 days', NOW() - INTERVAL '5 hours'),
  ('00000000-0000-0000-0000-000000000008', 'demo-drew',   'drew@devpulse.dev',   'Drew Santos',   '', 'online',  'Platform engineer. Terraform & AWS.',            NOW() - INTERVAL '50 days', NOW() - INTERVAL '15 minutes')
ON CONFLICT (firebase_uid) DO NOTHING;

-- 2. TEAMS
INSERT INTO teams (id, name, slug, description, avatar_url, created_by, created_at, updated_at) VALUES
  ('10000000-0000-0000-0000-000000000001', 'Platform Core',  'platform-core',  'Core infrastructure and platform services',         '', '00000000-0000-0000-0000-000000000001', NOW() - INTERVAL '85 days', NOW() - INTERVAL '2 days'),
  ('10000000-0000-0000-0000-000000000002', 'Frontend Guild', 'frontend-guild', 'Frontend architecture and design systems',          '', '00000000-0000-0000-0000-000000000002', NOW() - INTERVAL '82 days', NOW() - INTERVAL '1 day'),
  ('10000000-0000-0000-0000-000000000003', 'Data Pipeline',  'data-pipeline',  'Data ingestion, processing, and analytics',         '', '00000000-0000-0000-0000-000000000003', NOW() - INTERVAL '80 days', NOW() - INTERVAL '3 days')
ON CONFLICT (slug) DO NOTHING;

-- 3. TEAM MEMBERS
INSERT INTO team_members (team_id, user_id, role, joined_at) VALUES
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'owner',  NOW() - INTERVAL '85 days'),
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'admin',  NOW() - INTERVAL '84 days'),
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', 'member', NOW() - INTERVAL '80 days'),
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000008', 'member', NOW() - INTERVAL '50 days'),
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000006', 'member', NOW() - INTERVAL '45 days')
ON CONFLICT (team_id, user_id) DO NOTHING;

INSERT INTO team_members (team_id, user_id, role, joined_at) VALUES
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'owner',  NOW() - INTERVAL '82 days'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', 'admin',  NOW() - INTERVAL '75 days'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'member', NOW() - INTERVAL '78 days'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000007', 'member', NOW() - INTERVAL '55 days'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000005', 'member', NOW() - INTERVAL '60 days')
ON CONFLICT (team_id, user_id) DO NOTHING;

INSERT INTO team_members (team_id, user_id, role, joined_at) VALUES
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', 'owner',  NOW() - INTERVAL '80 days'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000005', 'admin',  NOW() - INTERVAL '70 days'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000008', 'admin',  NOW() - INTERVAL '50 days'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000006', 'member', NOW() - INTERVAL '40 days'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004', 'member', NOW() - INTERVAL '35 days')
ON CONFLICT (team_id, user_id) DO NOTHING;

-- 4. PROJECTS
INSERT INTO projects (id, team_id, name, description, language, repo_url, created_by, created_at, updated_at) VALUES
  ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'API Gateway', 'High-performance API gateway with rate limiting, circuit breaking, and request transformation.', 'Go', 'https://github.com/devpulse/api-gateway', '00000000-0000-0000-0000-000000000001', NOW() - INTERVAL '80 days', NOW() - INTERVAL '3 days'),
  ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'Auth Service', 'Centralized authentication and authorization service. JWT tokens, RBAC policies, OAuth2 integrations.', 'Rust', 'https://github.com/devpulse/auth-service', '00000000-0000-0000-0000-000000000002', NOW() - INTERVAL '75 days', NOW() - INTERVAL '5 days'),
  ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000002', 'Design System', 'Shared component library with tokens, primitives, and composed patterns. Svelte 5 runes, Tailwind CSS 4.', 'TypeScript', 'https://github.com/devpulse/design-system', '00000000-0000-0000-0000-000000000004', NOW() - INTERVAL '70 days', NOW() - INTERVAL '1 day'),
  ('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000003', 'Ingestion Pipeline', 'Real-time data ingestion pipeline processing 50k events/sec. Apache Kafka consumers, schema validation.', 'Python', 'https://github.com/devpulse/ingestion-pipeline', '00000000-0000-0000-0000-000000000005', NOW() - INTERVAL '65 days', NOW() - INTERVAL '2 days'),
  ('20000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000002', 'Mobile Companion', 'Native mobile app for push notifications, quick status updates, and code review approvals.', 'Swift', 'https://github.com/devpulse/mobile-companion', '00000000-0000-0000-0000-000000000007', NOW() - INTERVAL '40 days', NOW() - INTERVAL '7 days')
ON CONFLICT DO NOTHING;

-- 5. ROOMS
INSERT INTO rooms (id, name, description, language, team_id, project_id, created_by, is_active, created_at, updated_at) VALUES
  ('30000000-0000-0000-0000-000000000001', 'API Gateway Refactor', 'Refactoring the middleware chain to support async hooks and OpenTelemetry tracing.', 'go', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', true, NOW() - INTERVAL '14 days', NOW() - INTERVAL '2 hours'),
  ('30000000-0000-0000-0000-000000000002', 'Design System v2', 'Building out the next generation of shared components with Svelte 5 runes.', 'typescript', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004', true, NOW() - INTERVAL '10 days', NOW() - INTERVAL '45 minutes'),
  ('30000000-0000-0000-0000-000000000003', 'Batch Processor', 'Implementing the nightly batch processor for aggregating analytics events. PySpark job with Delta Lake.', 'python', '10000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000005', false, NOW() - INTERVAL '30 days', NOW() - INTERVAL '5 days')
ON CONFLICT DO NOTHING;

-- 6. ROOM MESSAGES
INSERT INTO room_messages (id, room_id, user_id, content, created_at) VALUES
  ('31000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'I''ve started extracting the rate limiter into its own middleware. Check lines 45-80.', NOW() - INTERVAL '13 days'),
  ('31000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Looks good. Should we use a token bucket or sliding window for the rate limiter?', NOW() - INTERVAL '13 days' + INTERVAL '5 minutes'),
  ('31000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Token bucket is simpler and handles bursts better. Let me sketch it out.', NOW() - INTERVAL '13 days' + INTERVAL '8 minutes'),
  ('31000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', 'The DataTable component needs virtualization for large datasets. Any preference on the approach?', NOW() - INTERVAL '9 days'),
  ('31000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000007', 'I''ve used tanstack/virtual before - works great with Svelte. Handles 100k rows easily.', NOW() - INTERVAL '9 days' + INTERVAL '10 minutes'),
  ('31000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000005', 'The Spark job keeps OOMing on the 90-day aggregation window. Need to repartition.', NOW() - INTERVAL '6 days')
ON CONFLICT DO NOTHING;

-- 7. DISCUSSIONS (each as a separate INSERT to isolate errors)
INSERT INTO discussions (id, team_id, project_id, title, content, author_id, is_pinned, tags, created_at, updated_at) VALUES
  ('40000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001',
   'RFC: API Gateway Middleware Pipeline Redesign',
   $$## Summary

The current middleware chain in our API Gateway uses a linear slice of handlers. As we add more cross-cutting concerns (tracing, auth, rate limiting, CORS, compression), the ordering becomes fragile and hard to test.

## Proposal

Replace the flat middleware slice with a **directed acyclic graph (DAG)** of middleware nodes. Each node declares its dependencies, and the runtime resolves execution order via topological sort.

```go
type Middleware struct {
    Name      string
    DependsOn []string
    Handler   func(next http.Handler) http.Handler
}

func BuildPipeline(middlewares []Middleware) (http.Handler, error) {
    sorted, err := topoSort(middlewares)
    if err != nil {
        return nil, fmt.Errorf("cycle detected: %w", err)
    }
    // chain in sorted order
}
```

## Benefits
- Explicit dependency declarations
- Automatic cycle detection
- Easier testing of individual middleware
- Self-documenting pipeline

## Drawbacks
- More complex than a simple slice
- Debugging execution order requires tooling

## Decision
Please vote with reactions: thumbs-up to proceed, thumbs-down to keep flat chain.$$,
   '00000000-0000-0000-0000-000000000001', true, ARRAY['architecture', 'rfc', 'go', 'api-gateway'],
   NOW() - INTERVAL '30 days', NOW() - INTERVAL '5 days')
ON CONFLICT DO NOTHING;

INSERT INTO discussions (id, team_id, project_id, title, content, author_id, is_pinned, tags, created_at, updated_at) VALUES
  ('40000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000003',
   'Code Review: DataTable Component - Virtual Scrolling Implementation',
   $$PR #247 adds virtual scrolling to the DataTable component.

## Changes
- New VirtualList.svelte primitive using IntersectionObserver
- DataTable now accepts virtual prop (default: false, auto-enabled above 500 rows)
- Row height estimation with dynamic measurement and cache
- Keyboard navigation preserved with aria-rowindex

## Testing
- Unit tests for row calculation logic
- Playwright tests for scroll behavior
- Benchmarked at 100k rows with < 16ms frame time

## Screenshots
Perf flamegraph shows 3x improvement in initial render for 10k rows.

Please review the accessibility aspects especially -- I want to make sure screen readers handle the virtualized rows correctly.$$,
   '00000000-0000-0000-0000-000000000004', false, ARRAY['code-review', 'svelte', 'performance', 'accessibility'],
   NOW() - INTERVAL '12 days', NOW() - INTERVAL '3 days')
ON CONFLICT DO NOTHING;

INSERT INTO discussions (id, team_id, project_id, title, content, author_id, is_pinned, tags, created_at, updated_at) VALUES
  ('40000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002',
   'Bug: JWT refresh race condition under concurrent requests',
   $$## Description

When multiple API requests fire simultaneously and the JWT is expired, each request independently triggers a token refresh. This causes:

1. Multiple refresh token calls to the auth provider
2. The first refresh invalidates the refresh token
3. Subsequent refresh attempts fail with 401
4. User gets logged out unexpectedly

## Steps to Reproduce
1. Log in and wait for the access token to expire (or set TTL to 5s)
2. Navigate to dashboard (triggers 4+ parallel API calls)
3. Observe network tab: multiple /auth/refresh calls
4. Second and third calls fail with 401

## Expected Behavior
Only one refresh should happen; other requests should queue behind it.

## Proposed Fix
Implement a refresh mutex/semaphore in the HTTP client. First request acquires the lock and refreshes. Others wait and reuse the new token.

## Priority
High - this affects all users with slow connections.$$,
   '00000000-0000-0000-0000-000000000006', false, ARRAY['bug', 'auth', 'rust', 'concurrency'],
   NOW() - INTERVAL '8 days', NOW() - INTERVAL '2 days')
ON CONFLICT DO NOTHING;

INSERT INTO discussions (id, team_id, project_id, title, content, author_id, is_pinned, tags, created_at, updated_at) VALUES
  ('40000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000004',
   'Proposal: Migrate batch jobs from Airflow to Dagster',
   $$## Context

Our Apache Airflow instance is becoming a bottleneck:
- DAG parsing takes 45s+ with 200 DAGs
- The scheduler frequently falls behind
- Testing DAGs locally is painful (need full Airflow env)
- Python dependencies conflict between DAGs

## Proposal

Migrate to **Dagster** for our batch processing orchestration.

### Why Dagster?
- **Software-defined assets**: Model data lineage as code
- **Local development**: dagster dev works out of the box
- **Type system**: IO managers enforce data contracts
- **Partitions**: First-class support for time-partitioned data
- **Testing**: Assets are just Python functions, easy to unit test

### Migration Plan
1. Week 1-2: Set up Dagster infrastructure alongside Airflow
2. Week 3-4: Migrate the 10 most critical DAGs
3. Week 5-6: Migrate remaining DAGs in batches
4. Week 7: Decommission Airflow

### Risks
- Learning curve for the team
- Dagster Cloud cost vs self-hosted Airflow
- Some Airflow operators have no Dagster equivalent

Let me know your thoughts. I can demo Dagster in our next team sync.$$,
   '00000000-0000-0000-0000-000000000005', false, ARRAY['proposal', 'python', 'data-pipeline', 'migration'],
   NOW() - INTERVAL '20 days', NOW() - INTERVAL '15 days')
ON CONFLICT DO NOTHING;

INSERT INTO discussions (id, team_id, project_id, title, content, author_id, is_pinned, tags, created_at, updated_at) VALUES
  ('40000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000001', NULL,
   'Question: gRPC vs REST for internal service communication',
   $$We currently use REST (JSON over HTTP/1.1) for all inter-service communication. As we scale to more microservices, should we consider gRPC?

## Comparison

| Aspect | REST | gRPC |
|--------|------|------|
| Protocol | HTTP/1.1 | HTTP/2 |
| Format | JSON (text) | Protobuf (binary) |
| Streaming | Polling/SSE | Bidirectional |
| Code gen | OpenAPI (optional) | Required (protoc) |
| Browser support | Native | Needs grpc-web |
| Latency | ~5ms overhead | ~1ms overhead |

## My Take

I think a hybrid approach makes sense:
- **External APIs**: REST (browser-friendly, well-understood)
- **Internal service-to-service**: gRPC (performance, type safety)
- **Streaming use cases**: gRPC streams (real-time feeds)

Has anyone here operated gRPC in production? What were the pain points?$$,
   '00000000-0000-0000-0000-000000000002', false, ARRAY['question', 'architecture', 'grpc', 'rest'],
   NOW() - INTERVAL '25 days', NOW() - INTERVAL '20 days')
ON CONFLICT DO NOTHING;

INSERT INTO discussions (id, team_id, project_id, title, content, author_id, is_pinned, tags, created_at, updated_at) VALUES
  ('40000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000003', NULL,
   'RFC: Unified Observability Strategy',
   $$## Problem

We have fragmented observability:
- Metrics: Prometheus (some services) + CloudWatch (others)
- Logs: stdout to CloudWatch Logs (unstructured)
- Traces: None

Debugging production issues requires checking 3 different tools with no correlation.

## Proposal: OpenTelemetry Everything

Adopt OpenTelemetry as our single instrumentation standard.

### Architecture
```
Services --> OTel Collector --> | Metrics  --> Prometheus --> Grafana
                                | Traces   --> Tempo --> Grafana
                                | Logs     --> Loki --> Grafana
```

### Key Decisions
1. OTel SDK in every service (Go, Python, TypeScript)
2. OTel Collector as a sidecar in each pod
3. Grafana as the single pane of glass
4. Trace-to-log correlation via trace ID injection

### Rollout
- Phase 1: Go API gateway (highest traffic, most impact)
- Phase 2: Python data services
- Phase 3: Frontend (browser spans)

This is a significant investment but will dramatically improve our MTTR.$$,
   '00000000-0000-0000-0000-000000000003', true, ARRAY['rfc', 'observability', 'architecture', 'devops'],
   NOW() - INTERVAL '18 days', NOW() - INTERVAL '4 days')
ON CONFLICT DO NOTHING;

INSERT INTO discussions (id, team_id, project_id, title, content, author_id, is_pinned, tags, created_at, updated_at) VALUES
  ('40000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000003',
   'Performance: Bundle size regression in Design System v2.3',
   $$## Issue

After merging the icon library update in v2.3, our bundle size jumped from 42KB to 128KB (gzipped).

## Root Cause

The new icon package includes all 2,400 icons in a single entry point. Our tree-shaking is not working because the icons use side effects in their registration.

## Fix Options

1. **Per-icon imports**: Best tree-shaking, verbose imports
2. **Virtual module plugin**: Vite plugin that auto-generates imports - magic but great DX
3. **Icon sprite sheet**: Single SVG sprite, reference by ID - one HTTP request, no JS overhead

I'm prototyping option 2 this week. Will share benchmarks.$$,
   '00000000-0000-0000-0000-000000000004', false, ARRAY['performance', 'bundle-size', 'typescript', 'design-system'],
   NOW() - INTERVAL '7 days', NOW() - INTERVAL '2 days')
ON CONFLICT DO NOTHING;

INSERT INTO discussions (id, team_id, project_id, title, content, author_id, is_pinned, tags, created_at, updated_at) VALUES
  ('40000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001',
   'Question: Integration testing strategy for the gateway',
   $$We have good unit test coverage (~85%) on the API Gateway, but our integration tests are flaky and slow.

Current setup:
- Docker Compose spins up Postgres, Redis, downstream services
- Tests hit real HTTP endpoints
- Takes 8 minutes to run, fails ~20% of the time due to timing issues

## Ideas

1. **Testcontainers**: Spin up containers per test, better isolation
2. **Contract testing (Pact)**: Verify API contracts without real services
3. **In-process testing**: Use httptest.Server, mock external deps

I think we need a combination:
- Testcontainers for Postgres/Redis (real dependencies)
- Contract tests for downstream services (mock responses)
- httptest for handler-level tests (fastest feedback)

What has worked well for others?$$,
   '00000000-0000-0000-0000-000000000008', false, ARRAY['question', 'testing', 'go', 'ci-cd'],
   NOW() - INTERVAL '5 days', NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

INSERT INTO discussions (id, team_id, project_id, title, content, author_id, is_pinned, tags, created_at, updated_at) VALUES
  ('40000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000002', NULL,
   'Proposal: Storybook 8 with Svelte CSF3 for component development',
   $$## Background

Our component development workflow is:
1. Write component
2. Create a test page in the app
3. Manually test different prop combinations
4. Hope nothing breaks in other contexts

This is slow and error-prone.

## Proposal

Adopt **Storybook 8** with Svelte support (CSF3 format).

## Benefits
- Visual testing with Chromatic
- Auto-generated documentation
- Interactive prop playground
- Accessibility addon for a11y checks

I can set up the initial config this sprint if the team is on board.$$,
   '00000000-0000-0000-0000-000000000007', false, ARRAY['proposal', 'storybook', 'svelte', 'developer-experience'],
   NOW() - INTERVAL '3 days', NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

INSERT INTO discussions (id, team_id, project_id, title, content, author_id, is_pinned, tags, created_at, updated_at) VALUES
  ('40000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000003', NULL,
   'Post-mortem: Data pipeline outage on Feb 18',
   $$## Incident Summary

**Duration**: 2 hours 15 minutes (14:30 - 16:45 UTC)
**Impact**: Analytics data delayed by ~3 hours for all customers
**Severity**: P2

## Timeline
- 14:30 - Kafka consumer lag alert fires
- 14:35 - On-call (Jordan) acknowledges, begins investigation
- 14:50 - Root cause identified: schema registry OOM due to 500 new schemas from load test
- 15:10 - Schema registry restarted with increased memory (2GB -> 4GB)
- 15:30 - Consumer lag still growing; discovered 3 partitions reassigning
- 16:00 - Manual partition reassignment completed
- 16:30 - Lag decreasing, consumers caught up
- 16:45 - All clear, monitoring confirmed

## Root Cause

Load testing environment was misconfigured to register schemas against production registry. 500 new test schemas exhausted the registry memory.

## Action Items
- [ ] Separate schema registries per environment (Drew)
- [ ] Add memory alerts for schema registry (Jordan)
- [ ] Load test environment network isolation (Riley)
- [ ] Document schema registration limits in runbook (Casey)

## Lessons Learned
- Our Kafka monitoring caught the issue quickly (good)
- We lacked runbooks for schema registry issues (bad)
- Environment isolation is not just a nice-to-have (ugly)$$,
   '00000000-0000-0000-0000-000000000003', false, ARRAY['post-mortem', 'kafka', 'incident', 'data-pipeline'],
   NOW() - INTERVAL '14 days', NOW() - INTERVAL '14 days')
ON CONFLICT DO NOTHING;

-- 8. DISCUSSION REPLIES
INSERT INTO discussion_replies (id, discussion_id, parent_id, author_id, content, created_at, updated_at) VALUES
  ('41000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', NULL, '00000000-0000-0000-0000-000000000002',
   'Love the DAG approach. One concern: how do we handle middleware that needs to run both before and after the handler (e.g., timing/tracing)? With a flat chain it''s natural via defer, but with a DAG we''d need before/after hooks.',
   NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days'),
  ('41000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000001', '41000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
   'Great point Sam. The wrapper pattern naturally gives you before/after. The DAG only controls the wrapping order, not the execution model.',
   NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days'),
  ('41000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000002', NULL, '00000000-0000-0000-0000-000000000001',
   'The implementation looks solid. Two things: 1) aria-rowindex should be 1-based per WAI-ARIA spec, but I see 0-based in VirtualList.svelte line 87. 2) The row height cache should have a max size - LRU with 1000 entries should be plenty. Otherwise, ship it!',
   NOW() - INTERVAL '11 days', NOW() - INTERVAL '11 days'),
  ('41000000-0000-0000-0000-000000000004', '40000000-0000-0000-0000-000000000003', NULL, '00000000-0000-0000-0000-000000000002',
   'We hit this exact issue at my previous company. The mutex approach works but has a subtle edge case: if the refresh itself fails, all queued requests fail too. I''d suggest a refresh-ahead strategy: refresh the token 30 seconds before it expires, not on-demand.',
   NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days'),
  ('41000000-0000-0000-0000-000000000005', '40000000-0000-0000-0000-000000000004', NULL, '00000000-0000-0000-0000-000000000003',
   'I''ve been evaluating Dagster as well. The software-defined assets model is compelling for lineage tracking. I''d suggest we start with the daily user metrics aggregation as a proof of concept before committing to a full migration.',
   NOW() - INTERVAL '18 days', NOW() - INTERVAL '18 days'),
  ('41000000-0000-0000-0000-000000000006', '40000000-0000-0000-0000-000000000005', NULL, '00000000-0000-0000-0000-000000000008',
   'I ran gRPC in production for 2 years. Pain points: 1) Debugging is harder - binary protocol means no curl. 2) L4 load balancers distribute poorly with HTTP/2 long-lived connections. 3) Proto management across 15 repos was rough until we set up Buf. That said, p99 latency dropped from 12ms to 3ms.',
   NOW() - INTERVAL '23 days', NOW() - INTERVAL '23 days'),
  ('41000000-0000-0000-0000-000000000007', '40000000-0000-0000-0000-000000000006', NULL, '00000000-0000-0000-0000-000000000008',
   'Strongly in favor. OTel Collector as a sidecar is the right call - it decouples instrumentation from the backend. We should also instrument our database queries with otelsql for Go. Happy to help with the gateway rollout.',
   NOW() - INTERVAL '16 days', NOW() - INTERVAL '16 days'),
  ('41000000-0000-0000-0000-000000000008', '40000000-0000-0000-0000-000000000007', NULL, '00000000-0000-0000-0000-000000000002',
   'Option 2 (Vite virtual module) is what Nuxt uses for auto-imports and it works beautifully. Check out unplugin-icons - it already does exactly this and supports Svelte. Tree-shaking + great DX with zero custom code.',
   NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days'),
  ('41000000-0000-0000-0000-000000000009', '40000000-0000-0000-0000-000000000010', NULL, '00000000-0000-0000-0000-000000000006',
   'From a security perspective, this incident highlights why network segmentation matters. I also recommend we add schema registry to our threat model. Proposal: require schema registration to go through a CI pipeline with approval.',
   NOW() - INTERVAL '13 days', NOW() - INTERVAL '13 days')
ON CONFLICT DO NOTHING;

-- 9. REACTIONS
INSERT INTO reactions (id, target_type, target_id, user_id, emoji, created_at) VALUES
  ('60000000-0000-0000-0000-000000000001', 'discussion', '40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', '👍', NOW() - INTERVAL '29 days'),
  ('60000000-0000-0000-0000-000000000002', 'discussion', '40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', '👍', NOW() - INTERVAL '28 days'),
  ('60000000-0000-0000-0000-000000000003', 'discussion', '40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000006', '🚀', NOW() - INTERVAL '28 days'),
  ('60000000-0000-0000-0000-000000000004', 'discussion', '40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000008', '👍', NOW() - INTERVAL '27 days'),
  ('60000000-0000-0000-0000-000000000005', 'discussion', '40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004', '💡', NOW() - INTERVAL '27 days'),
  ('60000000-0000-0000-0000-000000000006', 'discussion', '40000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', '👀', NOW() - INTERVAL '7 days'),
  ('60000000-0000-0000-0000-000000000007', 'discussion', '40000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', '👍', NOW() - INTERVAL '7 days'),
  ('60000000-0000-0000-0000-000000000008', 'discussion', '40000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000001', '🚀', NOW() - INTERVAL '17 days'),
  ('60000000-0000-0000-0000-000000000009', 'discussion', '40000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000008', '👍', NOW() - INTERVAL '16 days'),
  ('60000000-0000-0000-0000-000000000010', 'discussion', '40000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000005', '💡', NOW() - INTERVAL '16 days'),
  ('60000000-0000-0000-0000-000000000011', 'discussion', '40000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000002', '🎉', NOW() - INTERVAL '15 days'),
  ('60000000-0000-0000-0000-000000000012', 'discussion', '40000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000001', '👀', NOW() - INTERVAL '13 days'),
  ('60000000-0000-0000-0000-000000000013', 'discussion', '40000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000005', '👍', NOW() - INTERVAL '13 days'),
  ('60000000-0000-0000-0000-000000000014', 'reply', '41000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', '💡', NOW() - INTERVAL '6 days'),
  ('60000000-0000-0000-0000-000000000015', 'reply', '41000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', '👍', NOW() - INTERVAL '6 days'),
  ('60000000-0000-0000-0000-000000000016', 'reply', '41000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000004', '🎉', NOW() - INTERVAL '5 days'),
  ('60000000-0000-0000-0000-000000000017', 'reply', '41000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000007', '👍', NOW() - INTERVAL '5 days')
ON CONFLICT (target_type, target_id, user_id, emoji) DO NOTHING;

-- 10. DOCUMENTS
INSERT INTO documents (id, team_id, parent_id, title, slug, content, author_id, sort_order, created_at, updated_at) VALUES
  ('50000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', NULL,
   'Getting Started Guide', 'getting-started',
   $$# Getting Started with DevPulse

Welcome to the DevPulse platform! This guide will help you set up your development environment and start contributing.

## Prerequisites

- **Go 1.22+** for backend services
- **Node.js 22+** with pnpm for frontend
- **Docker Desktop** for local infrastructure

## Quick Start

```bash
git clone https://github.com/devpulse/devpulse.git
cd devpulse
docker compose up -d
go run cmd/api/main.go
cd frontend && pnpm install && pnpm dev
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | API server port | 8080 |
| DATABASE_URL | PostgreSQL connection string | postgres://localhost:5433/devpulse |
| REDIS_URL | Redis connection string | redis://localhost:6380 |$$,
   '00000000-0000-0000-0000-000000000001', 0,
   NOW() - INTERVAL '85 days', NOW() - INTERVAL '10 days')
ON CONFLICT DO NOTHING;

INSERT INTO documents (id, team_id, parent_id, title, slug, content, author_id, sort_order, created_at, updated_at) VALUES
  ('50000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', NULL,
   'API Reference', 'api-reference',
   $$# API Reference

Base URL: http://localhost:8080/api

All endpoints require authentication via Bearer token.

## Teams
- GET /api/teams - List teams
- POST /api/teams - Create team
- GET /api/teams/:id - Get team

## Rooms
- GET /api/teams/:teamId/rooms - List rooms
- POST /api/teams/:teamId/rooms - Create room

## Discussions
- GET /api/teams/:teamId/discussions - List discussions
- POST /api/teams/:teamId/discussions - Create discussion

## WebSocket
Connect to ws://localhost:8080/ws/room/:roomId for real-time collaboration.$$,
   '00000000-0000-0000-0000-000000000002', 1,
   NOW() - INTERVAL '80 days', NOW() - INTERVAL '5 days')
ON CONFLICT DO NOTHING;

INSERT INTO documents (id, team_id, parent_id, title, slug, content, author_id, sort_order, created_at, updated_at) VALUES
  ('50000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', NULL,
   'Architecture Decision Records', 'architecture-decisions',
   $$# Architecture Decision Records (ADRs)

We use ADRs to document significant architectural decisions.

## ADR-001: Use PostgreSQL as Primary Database
**Status**: Accepted | **Date**: 2025-12-01
PostgreSQL 16 with UUID primary keys and JSONB for flexible metadata.

## ADR-002: Yjs for Real-Time Collaboration
**Status**: Accepted | **Date**: 2025-12-15
Yjs CRDT library with WebSocket transport for conflict-free editing.

## ADR-003: Firebase Auth for Identity
**Status**: Accepted | **Date**: 2025-12-01
Firebase Auth with custom token validation in the Go backend.

## ADR-004: sqlc for Type-Safe SQL
**Status**: Accepted | **Date**: 2026-01-10
sqlc generates Go code from SQL queries. SQL stays in .sql files.$$,
   '00000000-0000-0000-0000-000000000001', 2,
   NOW() - INTERVAL '78 days', NOW() - INTERVAL '20 days')
ON CONFLICT DO NOTHING;

INSERT INTO documents (id, team_id, parent_id, title, slug, content, author_id, sort_order, created_at, updated_at) VALUES
  ('50000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000003', NULL,
   'Deployment Guide', 'deployment-guide',
   $$# Deployment Guide

## Environments

| Environment | Cluster | URL |
|------------|---------|-----|
| Development | docker-compose | localhost:8080 |
| Staging | k8s-staging | staging.devpulse.dev |
| Production | k8s-prod | api.devpulse.dev |

## Local Development

```bash
docker compose up -d
docker compose ps
docker compose logs -f api
```

## Kubernetes Deployment

Production deployments go through the CI/CD pipeline:
1. Run tests
2. Build container image
3. Deploy to staging (auto)
4. Run smoke tests
5. Deploy to production (manual approval)$$,
   '00000000-0000-0000-0000-000000000003', 0,
   NOW() - INTERVAL '75 days', NOW() - INTERVAL '8 days')
ON CONFLICT DO NOTHING;

INSERT INTO documents (id, team_id, parent_id, title, slug, content, author_id, sort_order, created_at, updated_at) VALUES
  ('50000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000002', NULL,
   'Code Style Guide', 'code-style-guide',
   $$# Code Style Guide

Consistency makes code easier to read and review.

## General
- Use Prettier for formatting
- Use ESLint for linting
- Maximum line length: 100 characters
- Use tabs for indentation (Svelte ecosystem convention)

## Svelte Components
Follow this file structure: imports, props, state, derived, effects, functions.

## Go
- Follow Effective Go
- Use gofmt and golangci-lint
- Prefer table-driven tests

## Commit Messages
Follow Conventional Commits: feat, fix, docs, chore.$$,
   '00000000-0000-0000-0000-000000000004', 0,
   NOW() - INTERVAL '70 days', NOW() - INTERVAL '12 days')
ON CONFLICT DO NOTHING;

INSERT INTO documents (id, team_id, parent_id, title, slug, content, author_id, sort_order, created_at, updated_at) VALUES
  ('50000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000005',
   'Testing Strategy', 'testing-strategy',
   $$# Testing Strategy

Our testing pyramid guides how much effort we invest at each level.

## The Pyramid
- E2E (~10 tests, Playwright)
- Integration (~50 tests, Vitest + Testcontainers)
- Unit Tests (~200 tests, Vitest + Go testing)

## Frontend Testing
Use Svelte Testing Library for component interaction tests. Focus on user behavior, not implementation details.

## Backend Testing (Go)
Use table-driven tests for comprehensive coverage.

## Coverage Targets
- Backend: 80% line coverage
- Frontend components: 70% line coverage
- E2E: Cover all critical user journeys$$,
   '00000000-0000-0000-0000-000000000001', 0,
   NOW() - INTERVAL '60 days', NOW() - INTERVAL '15 days')
ON CONFLICT DO NOTHING;

INSERT INTO documents (id, team_id, parent_id, title, slug, content, author_id, sort_order, created_at, updated_at) VALUES
  ('50000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000003', NULL,
   'Monitoring & Alerting', 'monitoring-alerting',
   $$# Monitoring & Alerting

## Stack
- Prometheus - Metrics collection and storage
- Grafana - Dashboards and visualization
- AlertManager - Alert routing and silencing
- Loki - Log aggregation

## Alert Rules

| Alert | Condition | Severity |
|-------|-----------|----------|
| HighLatency | p95 > 500ms for 5m | Warning |
| HighErrorRate | 5xx > 1% for 5m | Critical |
| PodCrashLoop | restarts > 3 in 10m | Critical |
| DiskFull | disk > 85% | Warning |

## On-Call Rotation
Week rotation via PagerDuty with primary + secondary on-call.$$,
   '00000000-0000-0000-0000-000000000003', 1,
   NOW() - INTERVAL '55 days', NOW() - INTERVAL '4 days')
ON CONFLICT DO NOTHING;

INSERT INTO documents (id, team_id, parent_id, title, slug, content, author_id, sort_order, created_at, updated_at) VALUES
  ('50000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001',
   'Onboarding Checklist', 'onboarding-checklist',
   $$# New Team Member Onboarding Checklist

Welcome to DevPulse! Work through this checklist in your first two weeks.

## Week 1: Setup & Orientation
- [ ] Get access to GitHub org
- [ ] Set up local development environment
- [ ] Join Slack channels
- [ ] Read the Architecture Decision Records
- [ ] Read the Code Style Guide
- [ ] Run the test suite locally

## Week 1: First Contribution
- [ ] Pick a good-first-issue from the backlog
- [ ] Create a feature branch and open a PR
- [ ] Respond to review feedback and merge

## Week 2: Deep Dive
- [ ] Attend a code room session
- [ ] Review the API Reference
- [ ] Shadow an on-call shift
- [ ] Write or update one wiki document

## Buddy Program
Every new team member is paired with a buddy for their first month.$$,
   '00000000-0000-0000-0000-000000000001', 0,
   NOW() - INTERVAL '45 days', NOW() - INTERVAL '7 days')
ON CONFLICT DO NOTHING;

-- 11. DOCUMENT VERSIONS
INSERT INTO document_versions (id, document_id, title, content, author_id, version, created_at) VALUES
  ('51000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', 'Getting Started Guide', 'Initial version with basic setup instructions.', '00000000-0000-0000-0000-000000000001', 1, NOW() - INTERVAL '85 days'),
  ('51000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000001', 'Getting Started Guide', 'Added environment variables table and updated project structure.', '00000000-0000-0000-0000-000000000001', 2, NOW() - INTERVAL '40 days'),
  ('51000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000001', 'Getting Started Guide', 'Updated for Go 1.22 and pnpm, added seed data instructions.', '00000000-0000-0000-0000-000000000008', 3, NOW() - INTERVAL '10 days'),
  ('51000000-0000-0000-0000-000000000004', '50000000-0000-0000-0000-000000000002', 'API Reference', 'Initial API reference with teams and rooms endpoints.', '00000000-0000-0000-0000-000000000002', 1, NOW() - INTERVAL '80 days'),
  ('51000000-0000-0000-0000-000000000005', '50000000-0000-0000-0000-000000000002', 'API Reference', 'Added discussions endpoints and WebSocket documentation.', '00000000-0000-0000-0000-000000000002', 2, NOW() - INTERVAL '5 days'),
  ('51000000-0000-0000-0000-000000000006', '50000000-0000-0000-0000-000000000005', 'Code Style Guide', 'Initial code style guide with TypeScript and Go conventions.', '00000000-0000-0000-0000-000000000004', 1, NOW() - INTERVAL '70 days'),
  ('51000000-0000-0000-0000-000000000007', '50000000-0000-0000-0000-000000000005', 'Code Style Guide', 'Added Svelte component guidelines and commit message format.', '00000000-0000-0000-0000-000000000004', 2, NOW() - INTERVAL '12 days')
ON CONFLICT DO NOTHING;

-- 12. ACTIVITIES
INSERT INTO activities (id, team_id, actor_id, action, target_type, target_id, target_name, metadata, created_at) VALUES
  ('70000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'created', 'project', '20000000-0000-0000-0000-000000000001', 'API Gateway', '{"language": "Go"}', NOW() - INTERVAL '80 days'),
  ('70000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'created', 'project', '20000000-0000-0000-0000-000000000002', 'Auth Service', '{"language": "Rust"}', NOW() - INTERVAL '75 days'),
  ('70000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', 'created', 'project', '20000000-0000-0000-0000-000000000003', 'Design System', '{"language": "TypeScript"}', NOW() - INTERVAL '70 days'),
  ('70000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000008', 'joined', 'team', '10000000-0000-0000-0000-000000000001', 'Platform Core', '{"role": "member"}', NOW() - INTERVAL '50 days'),
  ('70000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000007', 'joined', 'team', '10000000-0000-0000-0000-000000000002', 'Frontend Guild', '{"role": "member"}', NOW() - INTERVAL '55 days'),
  ('70000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'posted', 'discussion', '40000000-0000-0000-0000-000000000001', 'RFC: API Gateway Middleware Pipeline Redesign', '{"tags": ["architecture", "rfc"]}', NOW() - INTERVAL '30 days'),
  ('70000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'replied', 'discussion', '40000000-0000-0000-0000-000000000001', 'RFC: API Gateway Middleware Pipeline Redesign', '{}', NOW() - INTERVAL '29 days'),
  ('70000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'created', 'room', '30000000-0000-0000-0000-000000000001', 'API Gateway Refactor', '{"language": "go"}', NOW() - INTERVAL '14 days'),
  ('70000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', 'created', 'room', '30000000-0000-0000-0000-000000000002', 'Design System v2', '{"language": "typescript"}', NOW() - INTERVAL '10 days'),
  ('70000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', 'posted', 'discussion', '40000000-0000-0000-0000-000000000002', 'Code Review: DataTable Component', '{"tags": ["code-review"]}', NOW() - INTERVAL '12 days'),
  ('70000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000006', 'posted', 'discussion', '40000000-0000-0000-0000-000000000003', 'Bug: JWT refresh race condition', '{"tags": ["bug", "auth"]}', NOW() - INTERVAL '8 days'),
  ('70000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'updated', 'document', '50000000-0000-0000-0000-000000000001', 'Getting Started Guide', '{"version": 3}', NOW() - INTERVAL '10 days'),
  ('70000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', 'posted', 'discussion', '40000000-0000-0000-0000-000000000006', 'RFC: Unified Observability Strategy', '{"tags": ["rfc", "observability"]}', NOW() - INTERVAL '18 days'),
  ('70000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000005', 'created', 'project', '20000000-0000-0000-0000-000000000004', 'Ingestion Pipeline', '{"language": "Python"}', NOW() - INTERVAL '65 days'),
  ('70000000-0000-0000-0000-000000000015', '10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000007', 'created', 'project', '20000000-0000-0000-0000-000000000005', 'Mobile Companion', '{"language": "Swift"}', NOW() - INTERVAL '40 days')
ON CONFLICT DO NOTHING;

-- 13. NOTIFICATIONS
INSERT INTO notifications (id, user_id, type, title, content, link_url, is_read, created_at) VALUES
  ('80000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'reply', 'Sam Chen replied to your discussion', 'Love the DAG approach. One concern: how do we handle middleware that needs to run both before and after...', '/discussions/40000000-0000-0000-0000-000000000001', true, NOW() - INTERVAL '29 days'),
  ('80000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'mention', 'Riley Quinn mentioned you in a discussion', 'From a security perspective, this incident highlights why network segmentation matters...', '/discussions/40000000-0000-0000-0000-000000000010', true, NOW() - INTERVAL '13 days'),
  ('80000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'reply', 'Morgan Lee posted a code review', 'PR #247 adds virtual scrolling to the DataTable component. Please review the accessibility aspects.', '/discussions/40000000-0000-0000-0000-000000000002', false, NOW() - INTERVAL '12 days'),
  ('80000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'invite', 'You were added to Data Pipeline team', 'Jordan Park added you as a member of the Data Pipeline team.', '/teams/10000000-0000-0000-0000-000000000003', false, NOW() - INTERVAL '3 days'),
  ('80000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000001', 'mention', 'Drew Santos updated the Getting Started Guide', 'Updated the guide for Go 1.22 and added seed data instructions. Please review.', '/docs/50000000-0000-0000-0000-000000000001', false, NOW() - INTERVAL '10 days')
ON CONFLICT DO NOTHING;
