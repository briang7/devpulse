package websocket

import "encoding/json"

type MessageType string

const (
	MessageTypeJoin       MessageType = "join"
	MessageTypeLeave      MessageType = "leave"
	MessageTypeCursor     MessageType = "cursor"
	MessageTypeChat       MessageType = "chat"
	MessageTypePresence   MessageType = "presence"
	MessageTypeSync       MessageType = "sync"
	MessageTypeYjsUpdate  MessageType = "yjs_update"
)

type Message struct {
	Type    MessageType     `json:"type"`
	RoomID  string          `json:"roomId,omitempty"`
	UserID  string          `json:"userId,omitempty"`
	Name    string          `json:"name,omitempty"`
	Color   string          `json:"color,omitempty"`
	Payload json.RawMessage `json:"payload,omitempty"`
	Binary  []byte          `json:"-"` // For Yjs binary updates
}

type CursorPayload struct {
	Line   int    `json:"line"`
	Column int    `json:"column"`
	Name   string `json:"name"`
	Color  string `json:"color"`
}

type ChatPayload struct {
	Content   string `json:"content"`
	Timestamp int64  `json:"timestamp"`
}

type PresencePayload struct {
	Status string `json:"status"` // online, away, typing
	Name   string `json:"name"`
	Color  string `json:"color"`
}
