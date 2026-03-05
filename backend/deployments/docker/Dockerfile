# Build stage
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache gcc musl-dev

# Copy go mod files
COPY go.mod go.sum* ./

# Copy source
COPY . .

# Resolve dependencies and build
RUN go mod tidy && CGO_ENABLED=0 GOOS=linux go build -o /devpulse ./cmd/server

# Runtime stage
FROM alpine:3.19

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

COPY --from=builder /devpulse .
COPY database/migrations ./database/migrations

EXPOSE 8080

CMD ["./devpulse"]
