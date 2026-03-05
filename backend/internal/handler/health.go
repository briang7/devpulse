package handler

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/redis/go-redis/v9"
)

func Health(db *pgxpool.Pool, rdb *redis.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 3*time.Second)
		defer cancel()

		status := "ok"
		checks := gin.H{
			"database": "ok",
			"redis":    "ok",
		}

		if err := db.Ping(ctx); err != nil {
			status = "degraded"
			checks["database"] = "error: " + err.Error()
		}

		if err := rdb.Ping(ctx).Err(); err != nil {
			status = "degraded"
			checks["redis"] = "error: " + err.Error()
		}

		code := http.StatusOK
		if status != "ok" {
			code = http.StatusServiceUnavailable
		}

		c.JSON(code, gin.H{
			"status":  status,
			"service": "devpulse-api",
			"version": "1.0.0",
			"checks":  checks,
		})
	}
}
