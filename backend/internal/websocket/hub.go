package websocket

import (
	"sync"

	"github.com/briang7/devpulse/internal/service"
	"github.com/rs/zerolog/log"
)

type Hub struct {
	rooms      map[string]map[*Client]bool
	register   chan *Client
	unregister chan *Client
	broadcast  chan *BroadcastMessage
	services   *service.Services
	mu         sync.RWMutex
	done       chan struct{}
}

type BroadcastMessage struct {
	RoomID  string
	Message []byte
	Sender  *Client // nil = broadcast to all including sender
	Binary  bool
}

func NewHub(services *service.Services) *Hub {
	return &Hub{
		rooms:      make(map[string]map[*Client]bool),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		broadcast:  make(chan *BroadcastMessage, 256),
		services:   services,
		done:       make(chan struct{}),
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			if _, ok := h.rooms[client.roomID]; !ok {
				h.rooms[client.roomID] = make(map[*Client]bool)
			}
			h.rooms[client.roomID][client] = true
			count := len(h.rooms[client.roomID])
			h.mu.Unlock()

			log.Info().
				Str("room", client.roomID).
				Str("user", client.userID).
				Int("participants", count).
				Msg("Client joined room")

		case client := <-h.unregister:
			h.mu.Lock()
			if clients, ok := h.rooms[client.roomID]; ok {
				if _, exists := clients[client]; exists {
					delete(clients, client)
					close(client.send)
					if len(clients) == 0 {
						delete(h.rooms, client.roomID)
					}
				}
			}
			h.mu.Unlock()

			log.Info().
				Str("room", client.roomID).
				Str("user", client.userID).
				Msg("Client left room")

		case msg := <-h.broadcast:
			h.mu.RLock()
			if clients, ok := h.rooms[msg.RoomID]; ok {
				for client := range clients {
					if msg.Sender != nil && client == msg.Sender {
						continue // Skip sender
					}
					select {
					case client.send <- msg.Message:
					default:
						close(client.send)
						delete(clients, client)
					}
				}
			}
			h.mu.RUnlock()

		case <-h.done:
			return
		}
	}
}

func (h *Hub) Shutdown() {
	close(h.done)
}

func (h *Hub) Register(client *Client) {
	h.register <- client
}

func (h *Hub) Broadcast(msg *BroadcastMessage) {
	h.broadcast <- msg
}

func (h *Hub) GetRoomParticipants(roomID string) int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	if clients, ok := h.rooms[roomID]; ok {
		return len(clients)
	}
	return 0
}

func (h *Hub) GetActiveRooms() map[string]int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	result := make(map[string]int)
	for roomID, clients := range h.rooms {
		result[roomID] = len(clients)
	}
	return result
}
