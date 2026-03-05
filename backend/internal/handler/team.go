package handler

import (
	"net/http"

	"github.com/briang7/devpulse/internal/model"
	"github.com/briang7/devpulse/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type CreateTeamRequest struct {
	Name        string `json:"name" binding:"required"`
	Slug        string `json:"slug" binding:"required"`
	Description string `json:"description"`
	AvatarURL   string `json:"avatarUrl"`
}

type AddMemberRequest struct {
	Email string `json:"email" binding:"required,email"`
	Role  string `json:"role" binding:"required,oneof=admin member guest"`
}

type UpdateMemberRequest struct {
	Role string `json:"role" binding:"required,oneof=owner admin member guest"`
}

func ListTeams(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		user := getUser(c, services)
		if user == nil {
			return
		}

		teams, err := services.Teams.ListByUser(c.Request.Context(), user.ID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list teams"})
			return
		}

		c.JSON(http.StatusOK, teams)
	}
}

func CreateTeam(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		user := getUser(c, services)
		if user == nil {
			return
		}

		var req CreateTeamRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		team := &model.Team{
			Name:        req.Name,
			Slug:        req.Slug,
			Description: req.Description,
			AvatarURL:   req.AvatarURL,
			CreatedBy:   user.ID,
		}

		if err := services.Teams.Create(c.Request.Context(), team, user.ID); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create team"})
			return
		}

		c.JSON(http.StatusCreated, team)
	}
}

func GetTeam(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid team ID"})
			return
		}

		team, err := services.Teams.GetByID(c.Request.Context(), id)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Team not found"})
			return
		}

		// Get members
		members, _ := services.Teams.GetMembers(c.Request.Context(), id)

		c.JSON(http.StatusOK, gin.H{
			"team":    team,
			"members": members,
		})
	}
}

func UpdateTeam(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid team ID"})
			return
		}

		var req CreateTeamRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		team := &model.Team{
			ID:          id,
			Name:        req.Name,
			Slug:        req.Slug,
			Description: req.Description,
			AvatarURL:   req.AvatarURL,
		}

		if err := services.Teams.Update(c.Request.Context(), team); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update team"})
			return
		}

		c.JSON(http.StatusOK, team)
	}
}

func DeleteTeam(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid team ID"})
			return
		}

		if err := services.Teams.Delete(c.Request.Context(), id); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete team"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Team deleted"})
	}
}

func AddMember(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		teamID, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid team ID"})
			return
		}

		var req AddMemberRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		member := &model.TeamMember{
			TeamID: teamID,
			Role:   req.Role,
		}

		if err := services.Teams.AddMember(c.Request.Context(), member); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add member"})
			return
		}

		c.JSON(http.StatusCreated, member)
	}
}

func UpdateMember(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		teamID, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid team ID"})
			return
		}

		userID, err := uuid.Parse(c.Param("uid"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			return
		}

		var req UpdateMemberRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		if err := services.Teams.UpdateMember(c.Request.Context(), teamID, userID, req.Role); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update member"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Member updated"})
	}
}

func RemoveMember(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		teamID, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid team ID"})
			return
		}

		userID, err := uuid.Parse(c.Param("uid"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			return
		}

		if err := services.Teams.RemoveMember(c.Request.Context(), teamID, userID); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to remove member"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Member removed"})
	}
}

func ListProjects(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		teamID, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid team ID"})
			return
		}

		projects, err := services.Projects.ListByTeam(c.Request.Context(), teamID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list projects"})
			return
		}

		c.JSON(http.StatusOK, projects)
	}
}

func CreateProject(services *service.Services) gin.HandlerFunc {
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
			Name        string `json:"name" binding:"required"`
			Description string `json:"description"`
			Language    string `json:"language"`
			RepoURL     string `json:"repoUrl"`
		}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		project := &model.Project{
			TeamID:      teamID,
			Name:        req.Name,
			Description: req.Description,
			Language:    req.Language,
			RepoURL:     req.RepoURL,
			CreatedBy:   user.ID,
		}

		if err := services.Projects.Create(c.Request.Context(), project); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create project"})
			return
		}

		c.JSON(http.StatusCreated, project)
	}
}
