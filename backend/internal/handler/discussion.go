package handler

import (
	"net/http"

	"github.com/briang7/devpulse/internal/model"
	"github.com/briang7/devpulse/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func ListDiscussions(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		teamID, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid team ID"})
			return
		}

		discussions, err := services.Discussions.ListByTeam(c.Request.Context(), teamID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list discussions"})
			return
		}

		c.JSON(http.StatusOK, discussions)
	}
}

func CreateDiscussion(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		user := getUser(c, services)
		if user == nil {
			return
		}

		teamID, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid team ID"})
			return
		}

		var req struct {
			Title     string   `json:"title" binding:"required"`
			Content   string   `json:"content" binding:"required"`
			Tags      []string `json:"tags"`
			ProjectID string   `json:"projectId"`
		}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		discussion := &model.Discussion{
			TeamID:   teamID,
			Title:    req.Title,
			Content:  req.Content,
			AuthorID: user.ID,
			Tags:     req.Tags,
		}

		if req.ProjectID != "" {
			pid, _ := uuid.Parse(req.ProjectID)
			discussion.ProjectID = &pid
		}

		if err := services.Discussions.Create(c.Request.Context(), discussion); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create discussion"})
			return
		}

		c.JSON(http.StatusCreated, discussion)
	}
}

func GetDiscussion(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid discussion ID"})
			return
		}

		discussion, err := services.Discussions.GetByID(c.Request.Context(), id)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Discussion not found"})
			return
		}

		replies, _ := services.Discussions.GetReplies(c.Request.Context(), id)
		reactions, _ := services.Discussions.GetReactions(c.Request.Context(), "discussion", id)
		discussion.Reactions = reactions

		c.JSON(http.StatusOK, gin.H{
			"discussion": discussion,
			"replies":    replies,
		})
	}
}

func UpdateDiscussion(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid discussion ID"})
			return
		}

		var req struct {
			Title   string   `json:"title"`
			Content string   `json:"content"`
			Tags    []string `json:"tags"`
		}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		discussion := &model.Discussion{
			ID:      id,
			Title:   req.Title,
			Content: req.Content,
			Tags:    req.Tags,
		}

		if err := services.Discussions.Update(c.Request.Context(), discussion); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update discussion"})
			return
		}

		c.JSON(http.StatusOK, discussion)
	}
}

func DeleteDiscussion(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid discussion ID"})
			return
		}

		if err := services.Discussions.Delete(c.Request.Context(), id); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete discussion"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Discussion deleted"})
	}
}

func CreateReply(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		user := getUser(c, services)
		if user == nil {
			return
		}

		discussionID, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid discussion ID"})
			return
		}

		var req struct {
			Content  string `json:"content" binding:"required"`
			ParentID string `json:"parentId"`
		}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		reply := &model.DiscussionReply{
			DiscussionID: discussionID,
			AuthorID:     user.ID,
			Content:      req.Content,
		}

		if req.ParentID != "" {
			pid, _ := uuid.Parse(req.ParentID)
			reply.ParentID = &pid
		}

		if err := services.Discussions.CreateReply(c.Request.Context(), reply); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create reply"})
			return
		}

		c.JSON(http.StatusCreated, reply)
	}
}

func ToggleReaction(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		user := getUser(c, services)
		if user == nil {
			return
		}

		targetID, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
			return
		}

		var req struct {
			Emoji      string `json:"emoji" binding:"required"`
			TargetType string `json:"targetType" binding:"required,oneof=discussion reply"`
		}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		reaction := &model.Reaction{
			TargetType: req.TargetType,
			TargetID:   targetID,
			UserID:     user.ID,
			Emoji:      req.Emoji,
		}

		added, err := services.Discussions.ToggleReaction(c.Request.Context(), reaction)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to toggle reaction"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"added": added})
	}
}

func TogglePin(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid discussion ID"})
			return
		}

		if err := services.Discussions.TogglePin(c.Request.Context(), id); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to toggle pin"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Pin toggled"})
	}
}
