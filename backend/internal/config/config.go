package config

import (
	"os"
	"strconv"
	"strings"
)

type Config struct {
	Port            int
	Environment     string
	DatabaseURL     string
	RedisURL        string
	CORSOrigins     []string
	FirebaseProject string
}

func Load() *Config {
	return &Config{
		Port:            getEnvInt("PORT", 8080),
		Environment:     getEnv("ENVIRONMENT", "development"),
		DatabaseURL:     getEnv("DATABASE_URL", "postgres://devpulse:devpulse@localhost:5433/devpulse?sslmode=disable"),
		RedisURL:        getEnv("REDIS_URL", "redis://localhost:6380"),
		CORSOrigins:     strings.Split(getEnv("CORS_ORIGINS", "http://localhost:5173"), ","),
		FirebaseProject: getEnv("FIREBASE_PROJECT", "webvista-builder"),
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	if v := os.Getenv(key); v != "" {
		if i, err := strconv.Atoi(v); err == nil {
			return i
		}
	}
	return fallback
}
