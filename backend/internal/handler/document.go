package handler

import (
	"net/http"

	"github.com/briang7/devpulse/internal/model"
	"github.com/briang7/devpulse/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func ListDocuments(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		teamID, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid team ID"})
			return
		}

		docs, err := services.Documents.ListByTeam(c.Request.Context(), teamID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list documents"})
			return
		}

		c.JSON(http.StatusOK, docs)
	}
}

func CreateDocument(services *service.Services) gin.HandlerFunc {
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
			Title    string `json:"title" binding:"required"`
			Slug     string `json:"slug" binding:"required"`
			Content  string `json:"content"`
			ParentID string `json:"parentId"`
		}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		doc := &model.Document{
			TeamID:   teamID,
			Title:    req.Title,
			Slug:     req.Slug,
			Content:  req.Content,
			AuthorID: user.ID,
		}

		if req.ParentID != "" {
			pid, _ := uuid.Parse(req.ParentID)
			doc.ParentID = &pid
		}

		if err := services.Documents.Create(c.Request.Context(), doc); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create document"})
			return
		}

		c.JSON(http.StatusCreated, doc)
	}
}

func GetDocument(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid document ID"})
			return
		}

		doc, err := services.Documents.GetByID(c.Request.Context(), id)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Document not found"})
			return
		}

		c.JSON(http.StatusOK, doc)
	}
}

func UpdateDocument(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid document ID"})
			return
		}

		var req struct {
			Title    string `json:"title"`
			Slug     string `json:"slug"`
			Content  string `json:"content"`
			ParentID string `json:"parentId"`
		}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		doc := &model.Document{
			ID:      id,
			Title:   req.Title,
			Slug:    req.Slug,
			Content: req.Content,
		}

		if req.ParentID != "" {
			pid, _ := uuid.Parse(req.ParentID)
			doc.ParentID = &pid
		}

		if err := services.Documents.Update(c.Request.Context(), doc); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update document"})
			return
		}

		c.JSON(http.StatusOK, doc)
	}
}

func DeleteDocument(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid document ID"})
			return
		}

		if err := services.Documents.Delete(c.Request.Context(), id); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete document"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Document deleted"})
	}
}

func ListVersions(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		docID, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid document ID"})
			return
		}

		versions, err := services.Documents.GetVersions(c.Request.Context(), docID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list versions"})
			return
		}

		c.JSON(http.StatusOK, versions)
	}
}

func CreateVersion(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		user := getUser(c, services)
		if user == nil {
			return
		}

		docID, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid document ID"})
			return
		}

		var req struct {
			Title   string `json:"title" binding:"required"`
			Content string `json:"content" binding:"required"`
		}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		version := &model.DocumentVersion{
			DocumentID: docID,
			Title:      req.Title,
			Content:    req.Content,
			AuthorID:   user.ID,
		}

		if err := services.Documents.CreateVersion(c.Request.Context(), version); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create version"})
			return
		}

		c.JSON(http.StatusCreated, version)
	}
}
