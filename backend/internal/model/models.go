package model

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID          uuid.UUID `json:"id" db:"id"`
	FirebaseUID string    `json:"firebaseUid" db:"firebase_uid"`
	Email       string    `json:"email" db:"email"`
	DisplayName string    `json:"displayName" db:"display_name"`
	AvatarURL   string    `json:"avatarUrl" db:"avatar_url"`
	Status      string    `json:"status" db:"status"` // online, away, offline
	Bio         string    `json:"bio" db:"bio"`
	CreatedAt   time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt   time.Time `json:"updatedAt" db:"updated_at"`
}

type Team struct {
	ID          uuid.UUID `json:"id" db:"id"`
	Name        string    `json:"name" db:"name"`
	Slug        string    `json:"slug" db:"slug"`
	Description string    `json:"description" db:"description"`
	AvatarURL   string    `json:"avatarUrl" db:"avatar_url"`
	CreatedBy   uuid.UUID `json:"createdBy" db:"created_by"`
	CreatedAt   time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt   time.Time `json:"updatedAt" db:"updated_at"`
	MemberCount int       `json:"memberCount,omitempty"`
}

type TeamMember struct {
	TeamID   uuid.UUID `json:"teamId" db:"team_id"`
	UserID   uuid.UUID `json:"userId" db:"user_id"`
	Role     string    `json:"role" db:"role"` // owner, admin, member, guest
	JoinedAt time.Time `json:"joinedAt" db:"joined_at"`
	User     *User     `json:"user,omitempty"`
}

type Project struct {
	ID          uuid.UUID `json:"id" db:"id"`
	TeamID      uuid.UUID `json:"teamId" db:"team_id"`
	Name        string    `json:"name" db:"name"`
	Description string    `json:"description" db:"description"`
	Language    string    `json:"language" db:"language"`
	RepoURL     string    `json:"repoUrl" db:"repo_url"`
	CreatedBy   uuid.UUID `json:"createdBy" db:"created_by"`
	CreatedAt   time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt   time.Time `json:"updatedAt" db:"updated_at"`
}

type Room struct {
	ID          uuid.UUID `json:"id" db:"id"`
	Name        string    `json:"name" db:"name"`
	Description string    `json:"description" db:"description"`
	Language    string    `json:"language" db:"language"`
	TeamID      uuid.UUID `json:"teamId" db:"team_id"`
	ProjectID   *uuid.UUID `json:"projectId" db:"project_id"`
	CreatedBy   uuid.UUID `json:"createdBy" db:"created_by"`
	IsActive    bool      `json:"isActive" db:"is_active"`
	Content     []byte    `json:"content,omitempty" db:"content"` // Yjs document state
	CreatedAt   time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt   time.Time `json:"updatedAt" db:"updated_at"`
	Participants int      `json:"participants,omitempty"`
	Team        *Team     `json:"team,omitempty"`
}

type RoomMessage struct {
	ID        uuid.UUID `json:"id" db:"id"`
	RoomID    uuid.UUID `json:"roomId" db:"room_id"`
	UserID    uuid.UUID `json:"userId" db:"user_id"`
	Content   string    `json:"content" db:"content"`
	CreatedAt time.Time `json:"createdAt" db:"created_at"`
	User      *User     `json:"user,omitempty"`
}

type Discussion struct {
	ID        uuid.UUID `json:"id" db:"id"`
	TeamID    uuid.UUID `json:"teamId" db:"team_id"`
	ProjectID *uuid.UUID `json:"projectId" db:"project_id"`
	Title     string    `json:"title" db:"title"`
	Content   string    `json:"content" db:"content"`
	AuthorID  uuid.UUID `json:"authorId" db:"author_id"`
	IsPinned  bool      `json:"isPinned" db:"is_pinned"`
	Tags      []string  `json:"tags" db:"tags"`
	CreatedAt time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt time.Time `json:"updatedAt" db:"updated_at"`
	Author    *User     `json:"author,omitempty"`
	ReplyCount int      `json:"replyCount,omitempty"`
	Reactions  []Reaction `json:"reactions,omitempty"`
}

type DiscussionReply struct {
	ID           uuid.UUID `json:"id" db:"id"`
	DiscussionID uuid.UUID `json:"discussionId" db:"discussion_id"`
	ParentID     *uuid.UUID `json:"parentId" db:"parent_id"`
	AuthorID     uuid.UUID `json:"authorId" db:"author_id"`
	Content      string    `json:"content" db:"content"`
	CreatedAt    time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt    time.Time `json:"updatedAt" db:"updated_at"`
	Author       *User     `json:"author,omitempty"`
	Reactions    []Reaction `json:"reactions,omitempty"`
}

type Reaction struct {
	ID        uuid.UUID `json:"id" db:"id"`
	TargetType string   `json:"targetType" db:"target_type"` // discussion, reply
	TargetID  uuid.UUID `json:"targetId" db:"target_id"`
	UserID    uuid.UUID `json:"userId" db:"user_id"`
	Emoji     string    `json:"emoji" db:"emoji"`
	CreatedAt time.Time `json:"createdAt" db:"created_at"`
}

type Document struct {
	ID        uuid.UUID  `json:"id" db:"id"`
	TeamID    uuid.UUID  `json:"teamId" db:"team_id"`
	ParentID  *uuid.UUID `json:"parentId" db:"parent_id"`
	Title     string     `json:"title" db:"title"`
	Slug      string     `json:"slug" db:"slug"`
	Content   string     `json:"content" db:"content"`
	AuthorID  uuid.UUID  `json:"authorId" db:"author_id"`
	SortOrder int        `json:"sortOrder" db:"sort_order"`
	CreatedAt time.Time  `json:"createdAt" db:"created_at"`
	UpdatedAt time.Time  `json:"updatedAt" db:"updated_at"`
	Author    *User      `json:"author,omitempty"`
	Children  []Document `json:"children,omitempty"`
}

type DocumentVersion struct {
	ID         uuid.UUID `json:"id" db:"id"`
	DocumentID uuid.UUID `json:"documentId" db:"document_id"`
	Title      string    `json:"title" db:"title"`
	Content    string    `json:"content" db:"content"`
	AuthorID   uuid.UUID `json:"authorId" db:"author_id"`
	Version    int       `json:"version" db:"version"`
	CreatedAt  time.Time `json:"createdAt" db:"created_at"`
	Author     *User     `json:"author,omitempty"`
}

type Activity struct {
	ID         uuid.UUID  `json:"id" db:"id"`
	TeamID     uuid.UUID  `json:"teamId" db:"team_id"`
	ActorID    uuid.UUID  `json:"actorId" db:"actor_id"`
	Action     string     `json:"action" db:"action"` // created, updated, deleted, joined, left, posted, replied
	TargetType string     `json:"targetType" db:"target_type"` // room, discussion, document, team, project
	TargetID   uuid.UUID  `json:"targetId" db:"target_id"`
	TargetName string     `json:"targetName" db:"target_name"`
	Metadata   string     `json:"metadata" db:"metadata"` // JSON
	CreatedAt  time.Time  `json:"createdAt" db:"created_at"`
	Actor      *User      `json:"actor,omitempty"`
}

type Notification struct {
	ID        uuid.UUID `json:"id" db:"id"`
	UserID    uuid.UUID `json:"userId" db:"user_id"`
	Type      string    `json:"type" db:"type"` // mention, reply, invite
	Title     string    `json:"title" db:"title"`
	Content   string    `json:"content" db:"content"`
	LinkURL   string    `json:"linkUrl" db:"link_url"`
	IsRead    bool      `json:"isRead" db:"is_read"`
	CreatedAt time.Time `json:"createdAt" db:"created_at"`
}
