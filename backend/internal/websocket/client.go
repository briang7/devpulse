package websocket

import (
	"encoding/json"
	"time"

	"github.com/gorilla/websocket"
	"github.com/rs/zerolog/log"
)

const (
	writeWait      = 10 * time.Second
	pongWait       = 60 * time.Second
	pingPeriod     = (pongWait * 9) / 10
	maxMessageSize = 1024 * 1024 // 1MB for Yjs updates
)

type Client struct {
	hub    *Hub
	conn   *websocket.Conn
	send   chan []byte
	roomID string
	userID string
	name   string
	color  string
}

func NewClient(hub *Hub, conn *websocket.Conn, roomID, userID, name, color string) *Client {
	return &Client{
		hub:    hub,
		conn:   conn,
		send:   make(chan []byte, 256),
		roomID: roomID,
		userID: userID,
		name:   name,
		color:  color,
	}
}

func (c *Client) ReadPump() {
	defer func() {
		// Broadcast leave message
		leaveMsg := Message{
			Type:   MessageTypeLeave,
			RoomID: c.roomID,
			UserID: c.userID,
			Name:   c.name,
		}
		if data, err := json.Marshal(leaveMsg); err == nil {
			c.hub.broadcast <- &BroadcastMessage{
				RoomID:  c.roomID,
				Message: data,
				Sender:  nil,
			}
		}
		c.hub.unregister <- c
		c.conn.Close()
	}()

	c.conn.SetReadLimit(maxMessageSize)
	c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error {
		c.conn.SetReadDeadline(time.Now().Add(pongWait))
		return nil
	})

	for {
		messageType, data, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseNormalClosure) {
				log.Warn().Err(err).Str("user", c.userID).Msg("WebSocket read error")
			}
			break
		}

		// Handle binary messages (Yjs updates)
		if messageType == websocket.BinaryMessage {
			c.hub.broadcast <- &BroadcastMessage{
				RoomID:  c.roomID,
				Message: data,
				Sender:  c,
				Binary:  true,
			}
			continue
		}

		// Handle JSON messages
		var msg Message
		if err := json.Unmarshal(data, &msg); err != nil {
			log.Warn().Err(err).Msg("Invalid WebSocket message")
			continue
		}

		msg.RoomID = c.roomID
		msg.UserID = c.userID
		msg.Name = c.name

		outData, _ := json.Marshal(msg)
		c.hub.broadcast <- &BroadcastMessage{
			RoomID:  c.roomID,
			Message: outData,
			Sender:  c,
		}
	}
}

func (c *Client) WritePump() {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			if err := c.conn.WriteMessage(websocket.TextMessage, message); err != nil {
				return
			}

		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}
