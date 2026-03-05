package handler

import (
	"encoding/json"
	"net/http"

	"github.com/briang7/devpulse/internal/model"
	"github.com/briang7/devpulse/internal/service"
	ws "github.com/briang7/devpulse/internal/websocket"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // CORS handled by middleware
	},
}

type CreateRoomRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
	Language    string `json:"language" binding:"required"`
	TeamID      string `json:"teamId" binding:"required,uuid"`
	ProjectID   string `json:"projectId,omitempty"`
}

func ListRooms(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		user := getUser(c, services)
		if user == nil {
			return
		}

		rooms, err := services.Rooms.List(c.Request.Context(), user.ID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list rooms"})
			return
		}

		c.JSON(http.StatusOK, rooms)
	}
}

func CreateRoom(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		user := getUser(c, services)
		if user == nil {
			return
		}

		var req CreateRoomRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		teamID, _ := uuid.Parse(req.TeamID)
		room := &model.Room{
			Name:        req.Name,
			Description: req.Description,
			Language:    req.Language,
			TeamID:      teamID,
			CreatedBy:   user.ID,
		}

		if req.ProjectID != "" {
			pid, _ := uuid.Parse(req.ProjectID)
			room.ProjectID = &pid
		}

		if err := services.Rooms.Create(c.Request.Context(), room); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create room"})
			return
		}

		c.JSON(http.StatusCreated, room)
	}
}

func GetRoom(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid room ID"})
			return
		}

		room, err := services.Rooms.GetByID(c.Request.Context(), id)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Room not found"})
			return
		}

		c.JSON(http.StatusOK, room)
	}
}

func SaveRoomCode(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		user := getUser(c, services)
		if user == nil {
			return
		}

		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid room ID"})
			return
		}

		var req struct {
			Code string `json:"code"`
		}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		if err := services.Rooms.UpdateContent(c.Request.Context(), id, []byte(req.Code)); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save code"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Code saved"})
	}
}

func ListRoomMessages(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid room ID"})
			return
		}

		messages, err := services.Rooms.ListMessages(c.Request.Context(), id, 100)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list messages"})
			return
		}

		if messages == nil {
			messages = []model.RoomMessage{}
		}
		c.JSON(http.StatusOK, messages)
	}
}

func CreateRoomMessage(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		user := getUser(c, services)
		if user == nil {
			return
		}

		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid room ID"})
			return
		}

		var req struct {
			Content string `json:"content" binding:"required"`
		}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		msg := &model.RoomMessage{
			RoomID:  id,
			UserID:  user.ID,
			Content: req.Content,
		}

		if err := services.Rooms.CreateMessage(c.Request.Context(), msg); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create message"})
			return
		}

		msg.User = &model.User{
			ID:          user.ID,
			DisplayName: user.DisplayName,
			AvatarURL:   user.AvatarURL,
		}

		c.JSON(http.StatusCreated, msg)
	}
}

func DeleteRoom(services *service.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := uuid.Parse(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid room ID"})
			return
		}

		if err := services.Rooms.Delete(c.Request.Context(), id); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete room"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Room deleted"})
	}
}

// WebSocket handles WebSocket connections for code rooms
func WebSocket(hub *ws.Hub) gin.HandlerFunc {
	return func(c *gin.Context) {
		roomID := c.Param("roomId")
		userID := c.GetString("firebaseUID")
		name := c.Query("name")
		color := c.Query("color")

		if name == "" {
			name = "Anonymous"
		}
		if color == "" {
			color = "#7c3aed"
		}

		conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
		if err != nil {
			return
		}

		client := ws.NewClient(hub, conn, roomID, userID, name, color)
		hub.Register(client)

		// Broadcast join message
		joinMsg := ws.Message{
			Type:   ws.MessageTypeJoin,
			RoomID: roomID,
			UserID: userID,
			Name:   name,
			Color:  color,
		}
		if data, err := json.Marshal(joinMsg); err == nil {
			hub.Broadcast(&ws.BroadcastMessage{
				RoomID:  roomID,
				Message: data,
				Sender:  nil,
			})
		}

		go client.WritePump()
		go client.ReadPump()
	}
}

func getUser(c *gin.Context, services *service.Services) *model.User {
	firebaseUID := c.GetString("firebaseUID")
	user, err := services.Users.GetByFirebaseUID(c.Request.Context(), firebaseUID)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
		return nil
	}
	return user
}
