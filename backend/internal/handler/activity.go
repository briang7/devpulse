package handler

import (
	"net/http"
	"strconv"

	"github.com/briang7/devpulse/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func ListActivities(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		user := getUser(c, services)
		if user == nil {
			return
		}

		limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
		offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

		if limit > 100 {
			limit = 100
		}

		activities, err := services.Activities.List(c.Request.Context(), user.ID, limit, offset)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list activities"})
			return
		}

		c.JSON(http.StatusOK, activities)
	}
}

func ListNotifications(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		user := getUser(c, services)
		if user == nil {
			return
		}

		notifications, err := services.Activities.ListNotifications(c.Request.Context(), user.ID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list notifications"})
			return
		}

		c.JSON(http.StatusOK, notifications)
	}
}

func MarkRead(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		user := getUser(c, services)
		if user == nil {
			return
		}

		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid notification ID"})
			return
		}

		if err := services.Activities.MarkRead(c.Request.Context(), id, user.ID); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to mark notification as read"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Notification marked as read"})
	}
}
