.PHONY: dev build migrate seed test lint

# Development with Air hot-reload
dev:
	docker compose up -d postgres redis
	air

# Build Go binary
build:
	go build -o bin/devpulse ./cmd/server

# Run database migrations
migrate:
	docker compose exec api /app/devpulse migrate up

# Seed the database
seed:
	go run scripts/seed.go

# Run tests
test:
	go test ./... -v -count=1

# Lint
lint:
	golangci-lint run ./...

# Docker
docker-up:
	docker compose up -d

docker-down:
	docker compose down

docker-logs:
	docker compose logs -f api
