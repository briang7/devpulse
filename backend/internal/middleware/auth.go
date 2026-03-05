package middleware

import (
	"context"
	"net/http"
	"strings"
	"time"

	"github.com/briang7/devpulse/internal/config"
	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"
	"google.golang.org/api/idtoken"
)

// Auth validates Firebase ID tokens.
// In development mode, it accepts a simple header for testing.
func Auth(cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")

		// Also check query param for WebSocket connections
		if authHeader == "" {
			if token := c.Query("token"); token != "" {
				authHeader = "Bearer " + token
			}
		}

		if authHeader == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization header"})
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid authorization format"})
			return
		}

		token := parts[1]

		// Accept "dev:<uid>" tokens for demo/development
		if strings.HasPrefix(token, "dev:") {
			uid := strings.TrimPrefix(token, "dev:")
			c.Set("firebaseUID", uid)
			c.Next()
			return
		}

		// Validate Firebase ID token
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()

		payload, err := idtoken.Validate(ctx, token, cfg.FirebaseProject)
		if err != nil {
			log.Warn().Err(err).Msg("Invalid Firebase token")
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			return
		}

		uid, ok := payload.Claims["user_id"].(string)
		if !ok {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid token claims"})
			return
		}

		c.Set("firebaseUID", uid)
		c.Next()
	}
}
