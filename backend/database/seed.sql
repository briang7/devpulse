-- =============================================================================
-- DevPulse PostgreSQL Seed Data
-- =============================================================================
-- Comprehensive seed file for the DevPulse real-time collaboration platform.
-- Run against a database that already has the schema applied (001_initial_schema.up.sql).
-- All inserts use ON CONFLICT DO NOTHING for idempotent re-runs.
-- =============================================================================

BEGIN;

-- =============================================================================
-- 1. USERS (8 total: 3 demo users matching frontend auth store + 5 additional)
-- =============================================================================

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

-- =============================================================================
-- 2. TEAMS (3 teams)
-- =============================================================================

INSERT INTO teams (id, name, slug, description, avatar_url, created_by, created_at, updated_at) VALUES
  ('10000000-0000-0000-0000-000000000001', 'Platform Core',  'platform-core',  'Core infrastructure and platform services',         '', '00000000-0000-0000-0000-000000000001', NOW() - INTERVAL '85 days', NOW() - INTERVAL '2 days'),
  ('10000000-0000-0000-0000-000000000002', 'Frontend Guild', 'frontend-guild', 'Frontend architecture and design systems',          '', '00000000-0000-0000-0000-000000000002', NOW() - INTERVAL '82 days', NOW() - INTERVAL '1 day'),
  ('10000000-0000-0000-0000-000000000003', 'Data Pipeline',  'data-pipeline',  'Data ingestion, processing, and analytics',         '', '00000000-0000-0000-0000-000000000003', NOW() - INTERVAL '80 days', NOW() - INTERVAL '3 days')
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- 3. TEAM MEMBERS (all 8 users distributed across teams)
-- =============================================================================

-- Platform Core: Alex (owner), Sam (admin), Jordan (member), Drew (member), Riley (member)
INSERT INTO team_members (team_id, user_id, role, joined_at) VALUES
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'owner',  NOW() - INTERVAL '85 days'),
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'admin',  NOW() - INTERVAL '84 days'),
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', 'member', NOW() - INTERVAL '80 days'),
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000008', 'member', NOW() - INTERVAL '50 days'),
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000006', 'member', NOW() - INTERVAL '45 days')
ON CONFLICT (team_id, user_id) DO NOTHING;

-- Frontend Guild: Sam (owner), Morgan (admin), Alex (member), Avery (member), Casey (member)
INSERT INTO team_members (team_id, user_id, role, joined_at) VALUES
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'owner',  NOW() - INTERVAL '82 days'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', 'admin',  NOW() - INTERVAL '75 days'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'member', NOW() - INTERVAL '78 days'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000007', 'member', NOW() - INTERVAL '55 days'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000005', 'member', NOW() - INTERVAL '60 days')
ON CONFLICT (team_id, user_id) DO NOTHING;

-- Data Pipeline: Jordan (owner), Casey (admin), Drew (admin), Riley (member), Morgan (member)
INSERT INTO team_members (team_id, user_id, role, joined_at) VALUES
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', 'owner',  NOW() - INTERVAL '80 days'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000005', 'admin',  NOW() - INTERVAL '70 days'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000008', 'admin',  NOW() - INTERVAL '50 days'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000006', 'member', NOW() - INTERVAL '40 days'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004', 'member', NOW() - INTERVAL '35 days')
ON CONFLICT (team_id, user_id) DO NOTHING;

-- =============================================================================
-- 4. PROJECTS (5 projects across teams)
-- =============================================================================

INSERT INTO projects (id, team_id, name, description, language, repo_url, created_by, created_at, updated_at) VALUES
  ('20000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000001',
   'API Gateway',
   'High-performance API gateway with rate limiting, circuit breaking, and request transformation. Built on Go''s net/http with middleware chains.',
   'Go',
   'https://github.com/devpulse/api-gateway',
   '00000000-0000-0000-0000-000000000001',
   NOW() - INTERVAL '80 days', NOW() - INTERVAL '3 days'),

  ('20000000-0000-0000-0000-000000000002',
   '10000000-0000-0000-0000-000000000001',
   'Auth Service',
   'Centralized authentication and authorization service. JWT tokens, RBAC policies, OAuth2 provider integrations.',
   'Rust',
   'https://github.com/devpulse/auth-service',
   '00000000-0000-0000-0000-000000000002',
   NOW() - INTERVAL '75 days', NOW() - INTERVAL '5 days'),

  ('20000000-0000-0000-0000-000000000003',
   '10000000-0000-0000-0000-000000000002',
   'Design System',
   'Shared component library with tokens, primitives, and composed patterns. Svelte 5 runes, Tailwind CSS 4, Storybook.',
   'TypeScript',
   'https://github.com/devpulse/design-system',
   '00000000-0000-0000-0000-000000000004',
   NOW() - INTERVAL '70 days', NOW() - INTERVAL '1 day'),

  ('20000000-0000-0000-0000-000000000004',
   '10000000-0000-0000-0000-000000000003',
   'Ingestion Pipeline',
   'Real-time data ingestion pipeline processing 50k events/sec. Apache Kafka consumers, schema validation, dead-letter queues.',
   'Python',
   'https://github.com/devpulse/ingestion-pipeline',
   '00000000-0000-0000-0000-000000000005',
   NOW() - INTERVAL '65 days', NOW() - INTERVAL '2 days'),

  ('20000000-0000-0000-0000-000000000005',
   '10000000-0000-0000-0000-000000000002',
   'Mobile Companion',
   'Native mobile app for push notifications, quick status updates, and code review approvals on the go.',
   'Swift',
   'https://github.com/devpulse/mobile-companion',
   '00000000-0000-0000-0000-000000000007',
   NOW() - INTERVAL '40 days', NOW() - INTERVAL '7 days')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 5. ROOMS (3 live code collaboration rooms)
-- =============================================================================

INSERT INTO rooms (id, name, description, language, team_id, project_id, created_by, is_active, created_at, updated_at) VALUES
  ('30000000-0000-0000-0000-000000000001',
   'API Gateway Refactor',
   'Refactoring the middleware chain to support async hooks and OpenTelemetry tracing. Focus on the handler pipeline in pkg/gateway/middleware.go.',
   'go',
   '10000000-0000-0000-0000-000000000001',
   '20000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001',
   true,
   NOW() - INTERVAL '14 days', NOW() - INTERVAL '2 hours'),

  ('30000000-0000-0000-0000-000000000002',
   'Design System v2',
   'Building out the next generation of shared components with Svelte 5 runes. Currently working on the DataTable and ComboBox primitives.',
   'typescript',
   '10000000-0000-0000-0000-000000000002',
   '20000000-0000-0000-0000-000000000003',
   '00000000-0000-0000-0000-000000000004',
   true,
   NOW() - INTERVAL '10 days', NOW() - INTERVAL '45 minutes'),

  ('30000000-0000-0000-0000-000000000003',
   'Batch Processor',
   'Implementing the nightly batch processor for aggregating analytics events into summary tables. PySpark job with Delta Lake output.',
   'python',
   '10000000-0000-0000-0000-000000000003',
   '20000000-0000-0000-0000-000000000004',
   '00000000-0000-0000-0000-000000000005',
   false,
   NOW() - INTERVAL '30 days', NOW() - INTERVAL '5 days')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 6. ROOM MESSAGES (chat messages in rooms)
-- =============================================================================

INSERT INTO room_messages (id, room_id, user_id, content, created_at) VALUES
  ('31000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
   'I''ve started extracting the rate limiter into its own middleware. Check lines 45-80.',
   NOW() - INTERVAL '13 days'),
  ('31000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002',
   'Looks good. Should we use a token bucket or sliding window for the rate limiter?',
   NOW() - INTERVAL '13 days' + INTERVAL '5 minutes'),
  ('31000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
   'Token bucket is simpler and handles bursts better. Let me sketch it out.',
   NOW() - INTERVAL '13 days' + INTERVAL '8 minutes'),
  ('31000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004',
   'The DataTable component needs virtualization for large datasets. Any preference on the approach?',
   NOW() - INTERVAL '9 days'),
  ('31000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000007',
   'I''ve used tanstack/virtual before - works great with Svelte. Handles 100k rows easily.',
   NOW() - INTERVAL '9 days' + INTERVAL '10 minutes'),
  ('31000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000005',
   'The Spark job keeps OOMing on the 90-day aggregation window. Need to repartition.',
   NOW() - INTERVAL '6 days')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 7. DISCUSSIONS (10 threaded discussions)
-- =============================================================================

INSERT INTO discussions (id, team_id, project_id, title, content, author_id, is_pinned, tags, created_at, updated_at) VALUES

  -- Discussion 1: Architecture RFC (pinned)
  ('40000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000001',
   '20000000-0000-0000-0000-000000000001',
   'RFC: API Gateway Middleware Pipeline Redesign',
   E'## Summary\n\nThe current middleware chain in our API Gateway uses a linear slice of handlers. As we add more cross-cutting concerns (tracing, auth, rate limiting, CORS, compression), the ordering becomes fragile and hard to test.\n\n## Proposal\n\nReplace the flat middleware slice with a **directed acyclic graph (DAG)** of middleware nodes. Each node declares its dependencies, and the runtime resolves execution order via topological sort.\n\n```go\ntype Middleware struct {\n    Name     string\n    DependsOn []string\n    Handler   func(next http.Handler) http.Handler\n}\n\nfunc BuildPipeline(middlewares []Middleware) (http.Handler, error) {\n    sorted, err := topoSort(middlewares)\n    if err != nil {\n        return nil, fmt.Errorf("cycle detected: %w", err)\n    }\n    // chain in sorted order\n}\n```\n\n## Benefits\n- Explicit dependency declarations\n- Automatic cycle detection\n- Easier testing of individual middleware\n- Self-documenting pipeline\n\n## Drawbacks\n- More complex than a simple slice\n- Debugging execution order requires tooling\n\n## Decision\nPlease vote with reactions: thumbs-up to proceed, thumbs-down to keep flat chain.',
   '00000000-0000-0000-0000-000000000001',
   true,
   ARRAY['architecture', 'rfc', 'go', 'api-gateway'],
   NOW() - INTERVAL '30 days', NOW() - INTERVAL '5 days'),

  -- Discussion 2: Code review discussion
  ('40000000-0000-0000-0000-000000000002',
   '10000000-0000-0000-0000-000000000002',
   '20000000-0000-0000-0000-000000000003',
   'Code Review: DataTable Component - Virtual Scrolling Implementation',
   E'PR #247 adds virtual scrolling to the DataTable component.\n\n## Changes\n- New `VirtualList.svelte` primitive using IntersectionObserver\n- DataTable now accepts `virtual` prop (default: false, auto-enabled above 500 rows)\n- Row height estimation with dynamic measurement and cache\n- Keyboard navigation preserved with aria-rowindex\n\n## Testing\n- Unit tests for row calculation logic\n- Playwright tests for scroll behavior\n- Benchmarked at 100k rows with < 16ms frame time\n\n## Screenshots\nPerf flamegraph shows 3x improvement in initial render for 10k rows.\n\nPlease review the accessibility aspects especially -- I want to make sure screen readers handle the virtualized rows correctly.',
   '00000000-0000-0000-0000-000000000004',
   false,
   ARRAY['code-review', 'svelte', 'performance', 'accessibility'],
   NOW() - INTERVAL '12 days', NOW() - INTERVAL '3 days'),

  -- Discussion 3: Bug report
  ('40000000-0000-0000-0000-000000000003',
   '10000000-0000-0000-0000-000000000001',
   '20000000-0000-0000-0000-000000000002',
   'Bug: JWT refresh race condition under concurrent requests',
   E'## Description\n\nWhen multiple API requests fire simultaneously and the JWT is expired, each request independently triggers a token refresh. This causes:\n\n1. Multiple refresh token calls to the auth provider\n2. The first refresh invalidates the refresh token\n3. Subsequent refresh attempts fail with 401\n4. User gets logged out unexpectedly\n\n## Steps to Reproduce\n1. Log in and wait for the access token to expire (or set TTL to 5s)\n2. Navigate to dashboard (triggers 4+ parallel API calls)\n3. Observe network tab: multiple /auth/refresh calls\n4. Second and third calls fail with 401\n\n## Expected Behavior\nOnly one refresh should happen; other requests should queue behind it.\n\n## Proposed Fix\nImplement a refresh mutex/semaphore in the HTTP client:\n\n```rust\nlazy_static! {\n    static ref REFRESH_LOCK: Mutex<()> = Mutex::new(());\n}\n```\n\nFirst request acquires the lock and refreshes. Others wait and reuse the new token.\n\n## Priority\nHigh - this affects all users with slow connections.',
   '00000000-0000-0000-0000-000000000006',
   false,
   ARRAY['bug', 'auth', 'rust', 'concurrency'],
   NOW() - INTERVAL '8 days', NOW() - INTERVAL '2 days'),

  -- Discussion 4: Proposal
  ('40000000-0000-0000-0000-000000000004',
   '10000000-0000-0000-0000-000000000003',
   '20000000-0000-0000-0000-000000000004',
   'Proposal: Migrate batch jobs from Airflow to Dagster',
   E'## Context\n\nOur Apache Airflow instance is becoming a bottleneck:\n- DAG parsing takes 45s+ with 200 DAGs\n- The scheduler frequently falls behind\n- Testing DAGs locally is painful (need full Airflow env)\n- Python dependencies conflict between DAGs\n\n## Proposal\n\nMigrate to **Dagster** for our batch processing orchestration.\n\n### Why Dagster?\n- **Software-defined assets**: Model data lineage as code\n- **Local development**: `dagster dev` works out of the box\n- **Type system**: IO managers enforce data contracts\n- **Partitions**: First-class support for time-partitioned data\n- **Testing**: Assets are just Python functions, easy to unit test\n\n### Migration Plan\n1. Week 1-2: Set up Dagster infrastructure alongside Airflow\n2. Week 3-4: Migrate the 10 most critical DAGs\n3. Week 5-6: Migrate remaining DAGs in batches\n4. Week 7: Decommission Airflow\n\n### Risks\n- Learning curve for the team\n- Dagster Cloud cost vs self-hosted Airflow\n- Some Airflow operators have no Dagster equivalent\n\nLet me know your thoughts. I can demo Dagster in our next team sync.',
   '00000000-0000-0000-0000-000000000005',
   false,
   ARRAY['proposal', 'python', 'data-pipeline', 'migration'],
   NOW() - INTERVAL '20 days', NOW() - INTERVAL '15 days'),

  -- Discussion 5: Architecture question
  ('40000000-0000-0000-0000-000000000005',
   '10000000-0000-0000-0000-000000000001',
   NULL,
   'Question: gRPC vs REST for internal service communication',
   E'We currently use REST (JSON over HTTP/1.1) for all inter-service communication. As we scale to more microservices, should we consider gRPC?\n\n## Comparison\n\n| Aspect | REST | gRPC |\n|--------|------|------|\n| Protocol | HTTP/1.1 | HTTP/2 |\n| Format | JSON (text) | Protobuf (binary) |\n| Streaming | Polling/SSE | Bidirectional |\n| Code gen | OpenAPI (optional) | Required (protoc) |\n| Browser support | Native | Needs grpc-web |\n| Latency | ~5ms overhead | ~1ms overhead |\n\n## My Take\n\nI think a hybrid approach makes sense:\n- **External APIs**: REST (browser-friendly, well-understood)\n- **Internal service-to-service**: gRPC (performance, type safety)\n- **Streaming use cases**: gRPC streams (real-time feeds)\n\nHas anyone here operated gRPC in production? What were the pain points?',
   '00000000-0000-0000-0000-000000000002',
   false,
   ARRAY['question', 'architecture', 'grpc', 'rest'],
   NOW() - INTERVAL '25 days', NOW() - INTERVAL '20 days'),

  -- Discussion 6: RFC (pinned)
  ('40000000-0000-0000-0000-000000000006',
   '10000000-0000-0000-0000-000000000003',
   NULL,
   'RFC: Unified Observability Strategy',
   E'## Problem\n\nWe have fragmented observability:\n- Metrics: Prometheus (some services) + CloudWatch (others)\n- Logs: stdout to CloudWatch Logs (unstructured)\n- Traces: None\n\nDebugging production issues requires checking 3 different tools with no correlation.\n\n## Proposal: OpenTelemetry Everything\n\nAdopt OpenTelemetry as our single instrumentation standard.\n\n### Architecture\n```\nServices --> OTel Collector --> | Metrics  --> Prometheus --> Grafana\n                                | Traces   --> Tempo --> Grafana\n                                | Logs     --> Loki --> Grafana\n```\n\n### Key Decisions\n1. **OTel SDK** in every service (Go, Python, TypeScript)\n2. **OTel Collector** as a sidecar in each pod\n3. **Grafana** as the single pane of glass\n4. **Trace-to-log correlation** via trace ID injection\n\n### Rollout\n- Phase 1: Go API gateway (highest traffic, most impact)\n- Phase 2: Python data services\n- Phase 3: Frontend (browser spans)\n\nThis is a significant investment but will dramatically improve our MTTR.',
   '00000000-0000-0000-0000-000000000003',
   true,
   ARRAY['rfc', 'observability', 'architecture', 'devops'],
   NOW() - INTERVAL '18 days', NOW() - INTERVAL '4 days'),

  -- Discussion 7: Performance investigation
  ('40000000-0000-0000-0000-000000000007',
   '10000000-0000-0000-0000-000000000002',
   '20000000-0000-0000-0000-000000000003',
   'Performance: Bundle size regression in Design System v2.3',
   E'## Issue\n\nAfter merging the icon library update in v2.3, our bundle size jumped from 42KB to 128KB (gzipped).\n\n## Root Cause\n\nThe new icon package includes all 2,400 icons in a single entry point. Our tree-shaking is not working because the icons use side effects in their registration.\n\n```typescript\n// This prevents tree-shaking:\nimport { registerIcons } from ''@devpulse/icons'';\nregisterIcons(); // side effect!\n```\n\n## Fix Options\n\n1. **Per-icon imports**: `import { IconCheck } from ''@devpulse/icons/check''`\n   - Best tree-shaking, verbose imports\n2. **Virtual module plugin**: Vite plugin that auto-generates imports\n   - Magic, but great DX\n3. **Icon sprite sheet**: Single SVG sprite, reference by ID\n   - One HTTP request, no JS overhead\n\nI''m prototyping option 2 this week. Will share benchmarks.',
   '00000000-0000-0000-0000-000000000004',
   false,
   ARRAY['performance', 'bundle-size', 'typescript', 'design-system'],
   NOW() - INTERVAL '7 days', NOW() - INTERVAL '2 days'),

  -- Discussion 8: Question about testing
  ('40000000-0000-0000-0000-000000000008',
   '10000000-0000-0000-0000-000000000001',
   '20000000-0000-0000-0000-000000000001',
   'Question: Integration testing strategy for the gateway',
   E'We have good unit test coverage (~85%) on the API Gateway, but our integration tests are flaky and slow.\n\nCurrent setup:\n- Docker Compose spins up Postgres, Redis, downstream services\n- Tests hit real HTTP endpoints\n- Takes 8 minutes to run, fails ~20% of the time due to timing issues\n\n## Ideas\n\n1. **Testcontainers**: Spin up containers per test, better isolation\n2. **Contract testing (Pact)**: Verify API contracts without real services\n3. **In-process testing**: Use httptest.Server, mock external deps\n\nI think we need a combination:\n- **Testcontainers** for Postgres/Redis (real dependencies)\n- **Contract tests** for downstream services (mock responses)\n- **httptest** for handler-level tests (fastest feedback)\n\nWhat has worked well for others?',
   '00000000-0000-0000-0000-000000000008',
   false,
   ARRAY['question', 'testing', 'go', 'ci-cd'],
   NOW() - INTERVAL '5 days', NOW() - INTERVAL '1 day'),

  -- Discussion 9: Proposal for developer experience
  ('40000000-0000-0000-0000-000000000009',
   '10000000-0000-0000-0000-000000000002',
   NULL,
   'Proposal: Storybook 8 with Svelte CSF3 for component development',
   E'## Background\n\nOur component development workflow is:\n1. Write component\n2. Create a test page in the app\n3. Manually test different prop combinations\n4. Hope nothing breaks in other contexts\n\nThis is slow and error-prone.\n\n## Proposal\n\nAdopt **Storybook 8** with Svelte support (CSF3 format).\n\n```typescript\nimport type { Meta, StoryObj } from ''@storybook/svelte'';\nimport Button from ''./Button.svelte'';\n\nconst meta = {\n  component: Button,\n  tags: [''autodocs''],\n} satisfies Meta<Button>;\n\nexport default meta;\ntype Story = StoryObj<typeof meta>;\n\nexport const Primary: Story = {\n  args: { variant: ''primary'', label: ''Click me'' },\n};\n\nexport const Disabled: Story = {\n  args: { variant: ''primary'', label: ''Disabled'', disabled: true },\n};\n```\n\n## Benefits\n- Visual testing with Chromatic\n- Auto-generated documentation\n- Interactive prop playground\n- Accessibility addon for a11y checks\n\nI can set up the initial config this sprint if the team is on board.',
   '00000000-0000-0000-0000-000000000007',
   false,
   ARRAY['proposal', 'storybook', 'svelte', 'developer-experience'],
   NOW() - INTERVAL '3 days', NOW() - INTERVAL '1 day'),

  -- Discussion 10: Post-mortem
  ('40000000-0000-0000-0000-000000000010',
   '10000000-0000-0000-0000-000000000003',
   NULL,
   'Post-mortem: Data pipeline outage on Feb 18',
   E'## Incident Summary\n\n**Duration**: 2 hours 15 minutes (14:30 - 16:45 UTC)\n**Impact**: Analytics data delayed by ~3 hours for all customers\n**Severity**: P2\n\n## Timeline\n- 14:30 - Kafka consumer lag alert fires\n- 14:35 - On-call (Jordan) acknowledges, begins investigation\n- 14:50 - Root cause identified: schema registry OOM due to 500 new schemas from load test\n- 15:10 - Schema registry restarted with increased memory (2GB -> 4GB)\n- 15:30 - Consumer lag still growing; discovered 3 partitions reassigning\n- 16:00 - Manual partition reassignment completed\n- 16:30 - Lag decreasing, consumers caught up\n- 16:45 - All clear, monitoring confirmed\n\n## Root Cause\n\nLoad testing environment was misconfigured to register schemas against production registry. 500 new test schemas exhausted the registry''s memory.\n\n## Action Items\n- [ ] Separate schema registries per environment (Drew)\n- [ ] Add memory alerts for schema registry (Jordan)\n- [ ] Load test environment network isolation (Riley)\n- [ ] Document schema registration limits in runbook (Casey)\n\n## Lessons Learned\n- Our Kafka monitoring caught the issue quickly (good)\n- We lacked runbooks for schema registry issues (bad)\n- Environment isolation is not just a nice-to-have (ugly)',
   '00000000-0000-0000-0000-000000000003',
   false,
   ARRAY['post-mortem', 'kafka', 'incident', 'data-pipeline'],
   NOW() - INTERVAL '14 days', NOW() - INTERVAL '14 days')

ON CONFLICT DO NOTHING;

-- =============================================================================
-- 8. DISCUSSION REPLIES (9 replies across discussions)
-- =============================================================================

INSERT INTO discussion_replies (id, discussion_id, parent_id, author_id, content, created_at, updated_at) VALUES

  -- Reply 1: On the gateway RFC
  ('41000000-0000-0000-0000-000000000001',
   '40000000-0000-0000-0000-000000000001',
   NULL,
   '00000000-0000-0000-0000-000000000002',
   E'Love the DAG approach. One concern: how do we handle middleware that needs to run both before and after the handler (e.g., timing/tracing)? With a flat chain it''s natural via defer, but with a DAG we''d need before/after hooks.\n\nMaybe each middleware node could have `PreHandle` and `PostHandle` phases?',
   NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days'),

  -- Reply 2: Nested reply on the gateway RFC
  ('41000000-0000-0000-0000-000000000002',
   '40000000-0000-0000-0000-000000000001',
   '41000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001',
   E'Great point Sam. I think we can keep the standard `func(next http.Handler) http.Handler` signature. The wrapper pattern naturally gives you before/after:\n\n```go\nfunc TracingMiddleware(next http.Handler) http.Handler {\n    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {\n        span := tracer.Start(r.Context()) // before\n        defer span.End()                   // after\n        next.ServeHTTP(w, r)\n    })\n}\n```\n\nThe DAG only controls the wrapping order, not the execution model.',
   NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days'),

  -- Reply 3: On the DataTable code review
  ('41000000-0000-0000-0000-000000000003',
   '40000000-0000-0000-0000-000000000002',
   NULL,
   '00000000-0000-0000-0000-000000000001',
   E'The implementation looks solid. Two things from my review:\n\n1. `aria-rowindex` should be 1-based per the WAI-ARIA spec, but I see you''re using 0-based in `VirtualList.svelte` line 87.\n2. The row height cache should have a max size to prevent memory leaks with very dynamic content. A LRU cache with 1000 entries should be plenty.\n\nOtherwise, ship it!',
   NOW() - INTERVAL '11 days', NOW() - INTERVAL '11 days'),

  -- Reply 4: On the JWT bug
  ('41000000-0000-0000-0000-000000000004',
   '40000000-0000-0000-0000-000000000003',
   NULL,
   '00000000-0000-0000-0000-000000000002',
   E'We hit this exact issue at my previous company. The mutex approach works but has a subtle edge case: if the refresh itself fails (network timeout), all queued requests fail too.\n\nI''d suggest a **refresh-ahead** strategy: refresh the token 30 seconds before it expires, not on-demand. This way you''re never in the critical path.\n\n```rust\nfn schedule_refresh(expires_at: DateTime<Utc>) {\n    let refresh_at = expires_at - Duration::seconds(30);\n    tokio::spawn(async move {\n        sleep_until(refresh_at).await;\n        refresh_token().await;\n    });\n}\n```',
   NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days'),

  -- Reply 5: On the Dagster proposal
  ('41000000-0000-0000-0000-000000000005',
   '40000000-0000-0000-0000-000000000004',
   NULL,
   '00000000-0000-0000-0000-000000000003',
   E'I''ve been evaluating Dagster for our team as well. The software-defined assets model is really compelling for lineage tracking. One thing to consider: Dagster''s resource system is powerful but has a learning curve.\n\nI''d suggest we start with a single critical pipeline (the daily user metrics aggregation) as a proof of concept before committing to a full migration.',
   NOW() - INTERVAL '18 days', NOW() - INTERVAL '18 days'),

  -- Reply 6: On gRPC vs REST
  ('41000000-0000-0000-0000-000000000006',
   '40000000-0000-0000-0000-000000000005',
   NULL,
   '00000000-0000-0000-0000-000000000008',
   E'I ran gRPC in production for 2 years at my last role. Pain points:\n\n1. **Debugging is harder**: Binary protocol means you can''t just curl an endpoint. You need grpcurl or a dedicated client.\n2. **Load balancing**: gRPC uses HTTP/2 long-lived connections, so L4 load balancers distribute poorly. You need L7 (Envoy, Linkerd).\n3. **Proto management**: Keeping .proto files in sync across 15 repos was a nightmare until we set up Buf.\n\nThat said, the performance gains were real. Our p99 latency dropped from 12ms to 3ms on hot paths.',
   NOW() - INTERVAL '23 days', NOW() - INTERVAL '23 days'),

  -- Reply 7: On the observability RFC
  ('41000000-0000-0000-0000-000000000007',
   '40000000-0000-0000-0000-000000000006',
   NULL,
   '00000000-0000-0000-0000-000000000008',
   E'Strongly in favor of this. The OTel Collector as a sidecar is the right call -- it decouples instrumentation from the backend. If we ever want to switch from Prometheus to Datadog, we just reconfigure the collector.\n\nOne addition: we should also instrument our database queries. The `otel-instrumentation-sqlalchemy` and `otelsql` packages make this trivial for Python and Go respectively.\n\nHappy to help with the Go API gateway rollout since I''m already working on that codebase.',
   NOW() - INTERVAL '16 days', NOW() - INTERVAL '16 days'),

  -- Reply 8: On the bundle size regression
  ('41000000-0000-0000-0000-000000000008',
   '40000000-0000-0000-0000-000000000007',
   NULL,
   '00000000-0000-0000-0000-000000000002',
   E'Option 2 (Vite virtual module) is what Nuxt uses for their auto-imports and it works beautifully. The DX is seamless -- you just use `<IconCheck />` and the build tool figures out the import.\n\nFor the implementation, check out `unplugin-icons`. It already does exactly this and supports Svelte:\n\n```bash\nnpm i -D unplugin-icons @iconify-json/lucide\n```\n\nThis would get us tree-shaking + great DX with zero custom code.',
   NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days'),

  -- Reply 9: On the post-mortem
  ('41000000-0000-0000-0000-000000000009',
   '40000000-0000-0000-0000-000000000010',
   NULL,
   '00000000-0000-0000-0000-000000000006',
   E'From a security perspective, this incident highlights why network segmentation matters. I''ll work with Drew on the environment isolation item.\n\nI also recommend we add schema registry to our threat model. If a malicious actor could register arbitrary schemas, they could cause the same OOM in production intentionally.\n\nProposal: require schema registration to go through a CI pipeline with approval, not direct API calls.',
   NOW() - INTERVAL '13 days', NOW() - INTERVAL '13 days')

ON CONFLICT DO NOTHING;

-- =============================================================================
-- 9. REACTIONS (on discussions and replies)
-- =============================================================================

INSERT INTO reactions (id, target_type, target_id, user_id, emoji, created_at) VALUES
  -- Reactions on Discussion 1 (Gateway RFC) -- popular, many reactions
  ('60000000-0000-0000-0000-000000000001', 'discussion', '40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', '👍', NOW() - INTERVAL '29 days'),
  ('60000000-0000-0000-0000-000000000002', 'discussion', '40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', '👍', NOW() - INTERVAL '28 days'),
  ('60000000-0000-0000-0000-000000000003', 'discussion', '40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000006', '🔥', NOW() - INTERVAL '28 days'),
  ('60000000-0000-0000-0000-000000000004', 'discussion', '40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000008', '👍', NOW() - INTERVAL '27 days'),
  ('60000000-0000-0000-0000-000000000005', 'discussion', '40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004', '💡', NOW() - INTERVAL '27 days'),

  -- Reactions on Discussion 3 (JWT bug)
  ('60000000-0000-0000-0000-000000000006', 'discussion', '40000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', '👀', NOW() - INTERVAL '7 days'),
  ('60000000-0000-0000-0000-000000000007', 'discussion', '40000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', '👍', NOW() - INTERVAL '7 days'),

  -- Reactions on Discussion 6 (Observability RFC)
  ('60000000-0000-0000-0000-000000000008', 'discussion', '40000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000001', '🔥', NOW() - INTERVAL '17 days'),
  ('60000000-0000-0000-0000-000000000009', 'discussion', '40000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000008', '👍', NOW() - INTERVAL '16 days'),
  ('60000000-0000-0000-0000-000000000010', 'discussion', '40000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000005', '💡', NOW() - INTERVAL '16 days'),
  ('60000000-0000-0000-0000-000000000011', 'discussion', '40000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000002', '🎉', NOW() - INTERVAL '15 days'),

  -- Reactions on Discussion 10 (Post-mortem)
  ('60000000-0000-0000-0000-000000000012', 'discussion', '40000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000001', '👀', NOW() - INTERVAL '13 days'),
  ('60000000-0000-0000-0000-000000000013', 'discussion', '40000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000005', '👍', NOW() - INTERVAL '13 days'),

  -- Reactions on Reply 4 (Sam's refresh-ahead suggestion)
  ('60000000-0000-0000-0000-000000000014', 'reply', '41000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', '💡', NOW() - INTERVAL '6 days'),
  ('60000000-0000-0000-0000-000000000015', 'reply', '41000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', '👍', NOW() - INTERVAL '6 days'),

  -- Reactions on Reply 8 (Sam's unplugin-icons suggestion)
  ('60000000-0000-0000-0000-000000000016', 'reply', '41000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000004', '🎉', NOW() - INTERVAL '5 days'),
  ('60000000-0000-0000-0000-000000000017', 'reply', '41000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000007', '👍', NOW() - INTERVAL '5 days')

ON CONFLICT (target_type, target_id, user_id, emoji) DO NOTHING;

-- =============================================================================
-- 10. DOCUMENTS (8 wiki documents with parent-child relationships)
-- =============================================================================

INSERT INTO documents (id, team_id, parent_id, title, slug, content, author_id, sort_order, created_at, updated_at) VALUES

  -- Doc 1: Getting Started Guide (top-level, Platform Core)
  ('50000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000001',
   NULL,
   'Getting Started Guide',
   'getting-started',
   E'# Getting Started with DevPulse\n\nWelcome to the DevPulse platform! This guide will help you set up your development environment and start contributing.\n\n## Prerequisites\n\n- **Go 1.22+** for backend services\n- **Node.js 22+** with pnpm for frontend\n- **Docker Desktop** for local infrastructure\n- **VS Code** with recommended extensions (see `.vscode/extensions.json`)\n\n## Quick Start\n\n```bash\n# Clone the monorepo\ngit clone https://github.com/devpulse/devpulse.git\ncd devpulse\n\n# Start infrastructure (PostgreSQL, Redis)\ndocker compose up -d\n\n# Run database migrations\ngo run cmd/migrate/main.go up\n\n# Seed demo data\npsql -f database/seed.sql\n\n# Start the Go API server\ngo run cmd/api/main.go\n\n# In another terminal, start the frontend\ncd frontend && pnpm install && pnpm dev\n```\n\n## Project Structure\n\n```\ndevpulse/\n├── cmd/           # Application entry points\n├── internal/      # Private application code\n│   ├── api/       # HTTP handlers\n│   ├── ws/        # WebSocket hub\n│   └── db/        # Database queries (sqlc)\n├── frontend/      # SvelteKit application\n│   ├── src/lib/   # Shared components & stores\n│   └── src/routes/ # Page routes\n└── deployments/   # Docker, K8s configs\n```\n\n## Environment Variables\n\n| Variable | Description | Default |\n|----------|-------------|--------|\n| `PORT` | API server port | `8080` |\n| `DATABASE_URL` | PostgreSQL connection string | `postgres://devpulse:devpulse@localhost:5433/devpulse` |\n| `REDIS_URL` | Redis connection string | `redis://localhost:6380` |\n| `FIREBASE_PROJECT_ID` | Firebase project (auth) | `devpulse-dev` |\n\n## Need Help?\n\nPost a question in the **Platform Core** team discussions or ping `@alex` on the team chat.',
   '00000000-0000-0000-0000-000000000001',
   0,
   NOW() - INTERVAL '85 days', NOW() - INTERVAL '10 days'),

  -- Doc 2: API Reference (top-level, Platform Core)
  ('50000000-0000-0000-0000-000000000002',
   '10000000-0000-0000-0000-000000000001',
   NULL,
   'API Reference',
   'api-reference',
   E'# API Reference\n\nBase URL: `http://localhost:8080/api`\n\nAll endpoints require authentication via Bearer token in the `Authorization` header.\n\n## Authentication\n\n```bash\ncurl -H "Authorization: Bearer <firebase-token>" http://localhost:8080/api/teams\n```\n\nIn development mode, use `dev:<firebase_uid>` as the token (e.g., `dev:demo-alex`).\n\n## Teams\n\n### List Teams\n```\nGET /api/teams\n```\nReturns all teams the authenticated user belongs to.\n\n### Create Team\n```\nPOST /api/teams\nContent-Type: application/json\n\n{\n  "name": "My Team",\n  "slug": "my-team",\n  "description": "A new team"\n}\n```\n\n### Get Team\n```\nGET /api/teams/:id\n```\n\n## Rooms\n\n### List Rooms\n```\nGET /api/teams/:teamId/rooms\n```\n\n### Create Room\n```\nPOST /api/teams/:teamId/rooms\n\n{\n  "name": "Pair Programming",\n  "language": "typescript",\n  "description": "Working on the auth flow"\n}\n```\n\n## Discussions\n\n### List Discussions\n```\nGET /api/teams/:teamId/discussions\n```\n\n### Create Discussion\n```\nPOST /api/teams/:teamId/discussions\n\n{\n  "title": "RFC: New Feature",\n  "content": "## Summary\\n...",\n  "tags": ["rfc", "feature"]\n}\n```\n\n## WebSocket\n\nConnect to `ws://localhost:8080/ws/room/:roomId` for real-time code collaboration.\n\nSee the [Architecture Decision Records](./architecture-decisions) for protocol details.',
   '00000000-0000-0000-0000-000000000002',
   1,
   NOW() - INTERVAL '80 days', NOW() - INTERVAL '5 days'),

  -- Doc 3: Architecture Decision Records (top-level, Platform Core)
  ('50000000-0000-0000-0000-000000000003',
   '10000000-0000-0000-0000-000000000001',
   NULL,
   'Architecture Decision Records',
   'architecture-decisions',
   E'# Architecture Decision Records (ADRs)\n\nWe use ADRs to document significant architectural decisions. Each ADR is immutable once accepted -- if the decision changes, we write a new ADR that supersedes the old one.\n\n## ADR-001: Use PostgreSQL as Primary Database\n\n**Status**: Accepted\n**Date**: 2025-12-01\n**Context**: We need a relational database for structured data with strong consistency guarantees.\n**Decision**: PostgreSQL 16 with UUID primary keys and JSONB for flexible metadata.\n**Consequences**: Excellent ecosystem, great performance, but requires connection pooling for high concurrency.\n\n## ADR-002: Yjs for Real-Time Collaboration\n\n**Status**: Accepted\n**Date**: 2025-12-15\n**Context**: Code rooms need conflict-free real-time editing.\n**Decision**: Use Yjs CRDT library with WebSocket transport.\n**Consequences**: Automatic conflict resolution, offline support, but binary protocol requires custom tooling.\n\n## ADR-003: Firebase Auth for Identity\n\n**Status**: Accepted\n**Date**: 2025-12-01\n**Context**: We need authentication with social login support.\n**Decision**: Firebase Auth with custom token validation in the Go backend.\n**Consequences**: Quick setup, free tier is generous, but vendor lock-in for auth.\n\n## ADR-004: sqlc for Type-Safe SQL\n\n**Status**: Accepted\n**Date**: 2026-01-10\n**Context**: We want type-safe database access without an ORM.\n**Decision**: Use sqlc to generate Go code from SQL queries.\n**Consequences**: SQL stays in `.sql` files (reviewable), generated code is fast, but requires rebuild on schema changes.\n\n## Template\n\n```markdown\n## ADR-NNN: Title\n\n**Status**: Proposed | Accepted | Superseded by ADR-XXX\n**Date**: YYYY-MM-DD\n**Context**: What is the issue?\n**Decision**: What did we decide?\n**Consequences**: What are the trade-offs?\n```',
   '00000000-0000-0000-0000-000000000001',
   2,
   NOW() - INTERVAL '78 days', NOW() - INTERVAL '20 days'),

  -- Doc 4: Deployment Guide (top-level, Data Pipeline team)
  ('50000000-0000-0000-0000-000000000004',
   '10000000-0000-0000-0000-000000000003',
   NULL,
   'Deployment Guide',
   'deployment-guide',
   E'# Deployment Guide\n\n## Environments\n\n| Environment | Cluster | URL |\n|------------|---------|-----|\n| Development | docker-compose | localhost:8080 |\n| Staging | k8s-staging | staging.devpulse.dev |\n| Production | k8s-prod | api.devpulse.dev |\n\n## Local Development (Docker Compose)\n\n```bash\n# Start all services\ndocker compose up -d\n\n# Check status\ndocker compose ps\n\n# View logs\ndocker compose logs -f api\n\n# Tear down\ndocker compose down -v\n```\n\n## Kubernetes Deployment\n\n### Prerequisites\n- `kubectl` configured for the target cluster\n- `kustomize` v5+\n- Access to the container registry\n\n### Deploy to Staging\n```bash\n# Build and push the image\ndocker build -t registry.devpulse.dev/api:$(git rev-parse --short HEAD) .\ndocker push registry.devpulse.dev/api:$(git rev-parse --short HEAD)\n\n# Apply manifests\nkustomize build deployments/k8s/staging | kubectl apply -f -\n\n# Verify rollout\nkubectl rollout status deployment/devpulse-api -n devpulse-staging\n```\n\n### Deploy to Production\nProduction deployments go through the CI/CD pipeline. Merge to `main` triggers:\n1. Run tests\n2. Build container image\n3. Deploy to staging (auto)\n4. Run smoke tests\n5. Deploy to production (manual approval)\n\n## Rollback\n```bash\n# Quick rollback to previous version\nkubectl rollout undo deployment/devpulse-api -n devpulse-prod\n\n# Rollback to specific revision\nkubectl rollout undo deployment/devpulse-api --to-revision=42 -n devpulse-prod\n```\n\n## Database Migrations\n\nMigrations run automatically on deployment via an init container. To run manually:\n```bash\nkubectl exec -it deployment/devpulse-api -- /app/migrate up\n```',
   '00000000-0000-0000-0000-000000000003',
   0,
   NOW() - INTERVAL '75 days', NOW() - INTERVAL '8 days'),

  -- Doc 5: Code Style Guide (top-level, Frontend Guild)
  ('50000000-0000-0000-0000-000000000005',
   '10000000-0000-0000-0000-000000000002',
   NULL,
   'Code Style Guide',
   'code-style-guide',
   E'# Code Style Guide\n\nConsistency makes code easier to read and review. These are our agreed-upon conventions.\n\n## General\n\n- Use **Prettier** for formatting (config in `.prettierrc`)\n- Use **ESLint** for linting (config in `eslint.config.js`)\n- Maximum line length: 100 characters\n- Use tabs for indentation (Svelte ecosystem convention)\n\n## TypeScript\n\n```typescript\n// Prefer interfaces over type aliases for object shapes\ninterface User {\n  id: string;\n  name: string;\n  email: string;\n}\n\n// Use type aliases for unions and intersections\ntype Status = ''online'' | ''away'' | ''offline'';\n\n// Prefer const assertions for literal types\nconst ROLES = [''owner'', ''admin'', ''member''] as const;\ntype Role = (typeof ROLES)[number];\n\n// Avoid `any` - use `unknown` and narrow\nfunction parseJSON(input: string): unknown {\n  return JSON.parse(input);\n}\n```\n\n## Svelte Components\n\n```svelte\n<!-- Component file structure -->\n<script lang="ts">\n  // 1. Imports\n  // 2. Props ($props())\n  // 3. State ($state())\n  // 4. Derived ($derived())\n  // 5. Effects ($effect())\n  // 6. Functions\n</script>\n\n<!-- Template -->\n<div class="component-name">\n  <!-- content -->\n</div>\n\n<!-- Styles (prefer Tailwind, use style block for complex animations) -->\n<style>\n  /* scoped styles only when Tailwind isn''t enough */\n</style>\n```\n\n## Go\n\n- Follow [Effective Go](https://go.dev/doc/effective_go)\n- Use `gofmt` and `golangci-lint`\n- Error messages should not be capitalized or end with punctuation\n- Prefer table-driven tests\n\n```go\n// Good: descriptive function names\nfunc (s *TeamService) ListMembersByRole(ctx context.Context, teamID uuid.UUID, role string) ([]User, error)\n\n// Good: error wrapping with context\nreturn fmt.Errorf("list members for team %s: %w", teamID, err)\n```\n\n## Commit Messages\n\nFollow [Conventional Commits](https://www.conventionalcommits.org/):\n```\nfeat(rooms): add cursor presence indicators\nfix(auth): handle expired refresh tokens\ndocs(api): update WebSocket protocol spec\nchore(deps): bump svelte to 5.2\n```',
   '00000000-0000-0000-0000-000000000004',
   0,
   NOW() - INTERVAL '70 days', NOW() - INTERVAL '12 days'),

  -- Doc 6: Testing Strategy (child of Code Style Guide)
  ('50000000-0000-0000-0000-000000000006',
   '10000000-0000-0000-0000-000000000002',
   '50000000-0000-0000-0000-000000000005',
   'Testing Strategy',
   'testing-strategy',
   E'# Testing Strategy\n\nOur testing pyramid guides how much effort we invest at each level.\n\n## The Pyramid\n\n```\n         /  E2E  \\          (~10 tests, Playwright)\n        /----------\\        \n       / Integration \\       (~50 tests, Vitest + Testcontainers)\n      /----------------\\    \n     /    Unit Tests     \\    (~200 tests, Vitest + Go testing)\n    /----------------------\\\n```\n\n## Frontend Testing\n\n### Unit Tests (Vitest)\n```typescript\nimport { render, screen } from ''@testing-library/svelte'';\nimport Button from ''./Button.svelte'';\n\ntest(''renders label'', () => {\n  render(Button, { props: { label: ''Click me'' } });\n  expect(screen.getByText(''Click me'')).toBeInTheDocument();\n});\n```\n\n### Component Tests\nUse Svelte Testing Library for component interaction tests. Focus on user behavior, not implementation details.\n\n### E2E Tests (Playwright)\n```typescript\ntest(''can create a discussion'', async ({ page }) => {\n  await page.goto(''/teams/platform-core/discussions'');\n  await page.click(''button:has-text("New Discussion")'');\n  await page.fill(''[name=title]'', ''Test discussion'');\n  await page.click(''button:has-text("Post")'');\n  await expect(page.locator(''.discussion-title'')).toHaveText(''Test discussion'');\n});\n```\n\n## Backend Testing (Go)\n\n### Table-Driven Tests\n```go\nfunc TestValidateEmail(t *testing.T) {\n    tests := []struct {\n        name  string\n        email string\n        valid bool\n    }{\n        {"valid email", "user@example.com", true},\n        {"no at sign", "userexample.com", false},\n        {"empty string", "", false},\n    }\n    for _, tt := range tests {\n        t.Run(tt.name, func(t *testing.T) {\n            assert.Equal(t, tt.valid, ValidateEmail(tt.email))\n        })\n    }\n}\n```\n\n## Coverage Targets\n\n- Backend: 80% line coverage\n- Frontend components: 70% line coverage\n- E2E: Cover all critical user journeys',
   '00000000-0000-0000-0000-000000000001',
   0,
   NOW() - INTERVAL '60 days', NOW() - INTERVAL '15 days'),

  -- Doc 7: Monitoring & Alerting (top-level, Data Pipeline)
  ('50000000-0000-0000-0000-000000000007',
   '10000000-0000-0000-0000-000000000003',
   NULL,
   'Monitoring & Alerting',
   'monitoring-alerting',
   E'# Monitoring & Alerting\n\n## Stack\n\n- **Prometheus** - Metrics collection and storage\n- **Grafana** - Dashboards and visualization\n- **AlertManager** - Alert routing and silencing\n- **Loki** - Log aggregation\n\n## Dashboards\n\n### API Overview\n- Request rate (req/s) by endpoint\n- Latency percentiles (p50, p95, p99)\n- Error rate by status code\n- Active WebSocket connections\n\n### Database\n- Query latency by operation\n- Connection pool utilization\n- Transaction throughput\n- Slow query log (> 100ms)\n\n### Infrastructure\n- CPU / Memory / Disk per pod\n- Network I/O\n- Pod restart count\n\n## Alert Rules\n\n| Alert | Condition | Severity | Action |\n|-------|-----------|----------|--------|\n| HighLatency | p95 > 500ms for 5m | Warning | Check DB queries |\n| HighErrorRate | 5xx > 1% for 5m | Critical | Page on-call |\n| PodCrashLoop | restarts > 3 in 10m | Critical | Check logs |\n| DiskFull | disk > 85% | Warning | Scale PVC |\n| ConnectionPool | utilization > 90% | Warning | Increase pool |\n\n## On-Call Rotation\n\n- **Week rotation** via PagerDuty\n- Primary + secondary on-call\n- Escalation after 15 minutes if unacknowledged\n- Post-incident review within 48 hours\n\n## Runbooks\n\nSee child documents for specific runbooks:\n- [API Gateway Runbook](./api-gateway-runbook)\n- [Database Runbook](./database-runbook)',
   '00000000-0000-0000-0000-000000000003',
   1,
   NOW() - INTERVAL '55 days', NOW() - INTERVAL '4 days'),

  -- Doc 8: Onboarding Checklist (child of Getting Started Guide)
  ('50000000-0000-0000-0000-000000000008',
   '10000000-0000-0000-0000-000000000001',
   '50000000-0000-0000-0000-000000000001',
   'Onboarding Checklist',
   'onboarding-checklist',
   E'# New Team Member Onboarding Checklist\n\nWelcome to DevPulse! Work through this checklist in your first two weeks.\n\n## Week 1: Setup & Orientation\n\n- [ ] Get access to GitHub org (`devpulse`)\n- [ ] Set up local development environment (see [Getting Started](./getting-started))\n- [ ] Join the team Slack channels: `#platform-core`, `#frontend-guild`, `#data-pipeline`\n- [ ] Get added to PagerDuty rotation (shadow only for first month)\n- [ ] Read the [Architecture Decision Records](./architecture-decisions)\n- [ ] Read the [Code Style Guide](./code-style-guide)\n- [ ] Set up Firebase Auth credentials\n- [ ] Run the test suite locally and verify everything passes\n\n## Week 1: First Contribution\n\n- [ ] Pick a `good-first-issue` from the backlog\n- [ ] Create a feature branch (`feat/your-feature`)\n- [ ] Open a PR and request review from your buddy\n- [ ] Respond to review feedback and merge\n\n## Week 2: Deep Dive\n\n- [ ] Attend a code room session to see real-time collaboration\n- [ ] Read the [API Reference](./api-reference) for your team''s services\n- [ ] Review the [Monitoring & Alerting](./monitoring-alerting) setup\n- [ ] Shadow an on-call shift\n- [ ] Write or update one wiki document\n\n## Week 2: Social\n\n- [ ] Post an introduction in the `#introductions` channel\n- [ ] Schedule 1:1 coffee chats with 3 team members\n- [ ] Join the weekly team sync meeting\n- [ ] Participate in a discussion thread (ask a question or share an idea)\n\n## Buddy Program\n\nEvery new team member is paired with a buddy for their first month. Your buddy will:\n- Review your first PRs\n- Answer questions about codebase conventions\n- Help you navigate the team dynamics\n\nIf you don''t have a buddy assigned yet, ping `@alex` or `@sam`.',
   '00000000-0000-0000-0000-000000000001',
   0,
   NOW() - INTERVAL '45 days', NOW() - INTERVAL '7 days')

ON CONFLICT DO NOTHING;

-- =============================================================================
-- 11. DOCUMENT VERSIONS (version history for select documents)
-- =============================================================================

INSERT INTO document_versions (id, document_id, title, content, author_id, version, created_at) VALUES
  ('51000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', 'Getting Started Guide',
   'Initial version of the getting started guide with basic setup instructions.',
   '00000000-0000-0000-0000-000000000001', 1, NOW() - INTERVAL '85 days'),
  ('51000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000001', 'Getting Started Guide',
   'Added environment variables table and updated project structure.',
   '00000000-0000-0000-0000-000000000001', 2, NOW() - INTERVAL '40 days'),
  ('51000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000001', 'Getting Started Guide',
   'Updated for Go 1.22 and pnpm, added seed data instructions.',
   '00000000-0000-0000-0000-000000000008', 3, NOW() - INTERVAL '10 days'),

  ('51000000-0000-0000-0000-000000000004', '50000000-0000-0000-0000-000000000002', 'API Reference',
   'Initial API reference with teams and rooms endpoints.',
   '00000000-0000-0000-0000-000000000002', 1, NOW() - INTERVAL '80 days'),
  ('51000000-0000-0000-0000-000000000005', '50000000-0000-0000-0000-000000000002', 'API Reference',
   'Added discussions endpoints and WebSocket documentation.',
   '00000000-0000-0000-0000-000000000002', 2, NOW() - INTERVAL '5 days'),

  ('51000000-0000-0000-0000-000000000006', '50000000-0000-0000-0000-000000000005', 'Code Style Guide',
   'Initial code style guide with TypeScript and Go conventions.',
   '00000000-0000-0000-0000-000000000004', 1, NOW() - INTERVAL '70 days'),
  ('51000000-0000-0000-0000-000000000007', '50000000-0000-0000-0000-000000000005', 'Code Style Guide',
   'Added Svelte component structure guidelines and commit message format.',
   '00000000-0000-0000-0000-000000000004', 2, NOW() - INTERVAL '12 days')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 12. ACTIVITIES (15 activity feed entries)
-- =============================================================================

INSERT INTO activities (id, team_id, actor_id, action, target_type, target_id, target_name, metadata, created_at) VALUES
  ('70000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'created', 'project', '20000000-0000-0000-0000-000000000001', 'API Gateway',
   '{"language": "Go"}',
   NOW() - INTERVAL '80 days'),

  ('70000000-0000-0000-0000-000000000002',
   '10000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'created', 'project', '20000000-0000-0000-0000-000000000002', 'Auth Service',
   '{"language": "Rust"}',
   NOW() - INTERVAL '75 days'),

  ('70000000-0000-0000-0000-000000000003',
   '10000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000004',
   'created', 'project', '20000000-0000-0000-0000-000000000003', 'Design System',
   '{"language": "TypeScript"}',
   NOW() - INTERVAL '70 days'),

  ('70000000-0000-0000-0000-000000000004',
   '10000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000008',
   'joined', 'team', '10000000-0000-0000-0000-000000000001', 'Platform Core',
   '{"role": "member"}',
   NOW() - INTERVAL '50 days'),

  ('70000000-0000-0000-0000-000000000005',
   '10000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000007',
   'joined', 'team', '10000000-0000-0000-0000-000000000002', 'Frontend Guild',
   '{"role": "member"}',
   NOW() - INTERVAL '55 days'),

  ('70000000-0000-0000-0000-000000000006',
   '10000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'posted', 'discussion', '40000000-0000-0000-0000-000000000001', 'RFC: API Gateway Middleware Pipeline Redesign',
   '{"tags": ["architecture", "rfc"]}',
   NOW() - INTERVAL '30 days'),

  ('70000000-0000-0000-0000-000000000007',
   '10000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'replied', 'discussion', '40000000-0000-0000-0000-000000000001', 'RFC: API Gateway Middleware Pipeline Redesign',
   '{}',
   NOW() - INTERVAL '29 days'),

  ('70000000-0000-0000-0000-000000000008',
   '10000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'created', 'room', '30000000-0000-0000-0000-000000000001', 'API Gateway Refactor',
   '{"language": "go"}',
   NOW() - INTERVAL '14 days'),

  ('70000000-0000-0000-0000-000000000009',
   '10000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000004',
   'created', 'room', '30000000-0000-0000-0000-000000000002', 'Design System v2',
   '{"language": "typescript"}',
   NOW() - INTERVAL '10 days'),

  ('70000000-0000-0000-0000-000000000010',
   '10000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000004',
   'posted', 'discussion', '40000000-0000-0000-0000-000000000002', 'Code Review: DataTable Component',
   '{"tags": ["code-review"]}',
   NOW() - INTERVAL '12 days'),

  ('70000000-0000-0000-0000-000000000011',
   '10000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000006',
   'posted', 'discussion', '40000000-0000-0000-0000-000000000003', 'Bug: JWT refresh race condition',
   '{"tags": ["bug", "auth"]}',
   NOW() - INTERVAL '8 days'),

  ('70000000-0000-0000-0000-000000000012',
   '10000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'updated', 'document', '50000000-0000-0000-0000-000000000001', 'Getting Started Guide',
   '{"version": 3}',
   NOW() - INTERVAL '10 days'),

  ('70000000-0000-0000-0000-000000000013',
   '10000000-0000-0000-0000-000000000003',
   '00000000-0000-0000-0000-000000000003',
   'posted', 'discussion', '40000000-0000-0000-0000-000000000006', 'RFC: Unified Observability Strategy',
   '{"tags": ["rfc", "observability"]}',
   NOW() - INTERVAL '18 days'),

  ('70000000-0000-0000-0000-000000000014',
   '10000000-0000-0000-0000-000000000003',
   '00000000-0000-0000-0000-000000000005',
   'created', 'project', '20000000-0000-0000-0000-000000000004', 'Ingestion Pipeline',
   '{"language": "Python"}',
   NOW() - INTERVAL '65 days'),

  ('70000000-0000-0000-0000-000000000015',
   '10000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000007',
   'created', 'project', '20000000-0000-0000-0000-000000000005', 'Mobile Companion',
   '{"language": "Swift"}',
   NOW() - INTERVAL '40 days')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 13. NOTIFICATIONS (5 notifications for Alex - the demo user)
-- =============================================================================

INSERT INTO notifications (id, user_id, type, title, content, link_url, is_read, created_at) VALUES
  ('80000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'reply',
   'Sam Chen replied to your discussion',
   'Love the DAG approach. One concern: how do we handle middleware that needs to run both before and after the handler...',
   '/teams/platform-core/discussions/40000000-0000-0000-0000-000000000001',
   true,
   NOW() - INTERVAL '29 days'),

  ('80000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000001',
   'mention',
   'Riley Quinn mentioned you in a discussion',
   'From a security perspective, this incident highlights why network segmentation matters. Ping @alex for the post-mortem review.',
   '/teams/data-pipeline/discussions/40000000-0000-0000-0000-000000000010',
   true,
   NOW() - INTERVAL '13 days'),

  ('80000000-0000-0000-0000-000000000003',
   '00000000-0000-0000-0000-000000000001',
   'reply',
   'Morgan Lee posted a code review',
   'PR #247 adds virtual scrolling to the DataTable component. Please review the accessibility aspects.',
   '/teams/frontend-guild/discussions/40000000-0000-0000-0000-000000000002',
   false,
   NOW() - INTERVAL '12 days'),

  ('80000000-0000-0000-0000-000000000004',
   '00000000-0000-0000-0000-000000000001',
   'invite',
   'You were added to Data Pipeline team',
   'Jordan Park added you as a member of the Data Pipeline team. Check out the team discussions and projects.',
   '/teams/data-pipeline',
   false,
   NOW() - INTERVAL '3 days'),

  ('80000000-0000-0000-0000-000000000005',
   '00000000-0000-0000-0000-000000000001',
   'mention',
   'Drew Santos updated the Getting Started Guide',
   'Updated the guide for Go 1.22 and added seed data instructions. @alex please review since you wrote the original.',
   '/teams/platform-core/documents/getting-started',
   false,
   NOW() - INTERVAL '10 days')
ON CONFLICT DO NOTHING;

COMMIT;
