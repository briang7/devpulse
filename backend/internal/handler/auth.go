package handler

import (
	"net/http"

	"github.com/briang7/devpulse/internal/model"
	"github.com/briang7/devpulse/internal/service"
	"github.com/gin-gonic/gin"
)

type RegisterRequest struct {
	Email       string `json:"email" binding:"required,email"`
	DisplayName string `json:"displayName" binding:"required"`
	AvatarURL   string `json:"avatarUrl"`
}

func Register(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		var req RegisterRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		firebaseUID := c.GetString("firebaseUID")
		if firebaseUID == "" {
			// For registration, we accept the UID from the token
			firebaseUID = c.GetHeader("X-Firebase-UID")
		}

		user := &model.User{
			FirebaseUID: firebaseUID,
			Email:       req.Email,
			DisplayName: req.DisplayName,
			AvatarURL:   req.AvatarURL,
		}

		if err := services.Users.Create(c.Request.Context(), user); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
			return
		}

		c.JSON(http.StatusCreated, user)
	}
}

func Me(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		firebaseUID := c.GetString("firebaseUID")
		user, err := services.Users.GetByFirebaseUID(c.Request.Context(), firebaseUID)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			return
		}
		c.JSON(http.StatusOK, user)
	}
}
