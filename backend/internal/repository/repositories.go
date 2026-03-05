package repository

import (
	"context"
	"time"

	"github.com/briang7/devpulse/internal/model"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repositories struct {
	Users       *UserRepo
	Teams       *TeamRepo
	Projects    *ProjectRepo
	Rooms       *RoomRepo
	Discussions *DiscussionRepo
	Documents   *DocumentRepo
	Activities  *ActivityRepo
}

func NewRepositories(db *pgxpool.Pool) *Repositories {
	return &Repositories{
		Users:       &UserRepo{db: db},
		Teams:       &TeamRepo{db: db},
		Projects:    &ProjectRepo{db: db},
		Rooms:       &RoomRepo{db: db},
		Discussions: &DiscussionRepo{db: db},
		Documents:   &DocumentRepo{db: db},
		Activities:  &ActivityRepo{db: db},
	}
}

// UserRepo handles user database operations
type UserRepo struct {
	db *pgxpool.Pool
}

func (r *UserRepo) GetByFirebaseUID(ctx context.Context, uid string) (*model.User, error) {
	var u model.User
	err := r.db.QueryRow(ctx,
		`SELECT id, firebase_uid, email, display_name, avatar_url, status, bio, created_at, updated_at
		 FROM users WHERE firebase_uid = $1`, uid).
		Scan(&u.ID, &u.FirebaseUID, &u.Email, &u.DisplayName, &u.AvatarURL, &u.Status, &u.Bio, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &u, nil
}

func (r *UserRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.User, error) {
	var u model.User
	err := r.db.QueryRow(ctx,
		`SELECT id, firebase_uid, email, display_name, avatar_url, status, bio, created_at, updated_at
		 FROM users WHERE id = $1`, id).
		Scan(&u.ID, &u.FirebaseUID, &u.Email, &u.DisplayName, &u.AvatarURL, &u.Status, &u.Bio, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &u, nil
}

func (r *UserRepo) Create(ctx context.Context, u *model.User) error {
	u.ID = uuid.New()
	u.CreatedAt = time.Now()
	u.UpdatedAt = time.Now()
	if u.Status == "" {
		u.Status = "online"
	}
	_, err := r.db.Exec(ctx,
		`INSERT INTO users (id, firebase_uid, email, display_name, avatar_url, status, bio, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
		u.ID, u.FirebaseUID, u.Email, u.DisplayName, u.AvatarURL, u.Status, u.Bio, u.CreatedAt, u.UpdatedAt)
	return err
}

func (r *UserRepo) Update(ctx context.Context, u *model.User) error {
	u.UpdatedAt = time.Now()
	_, err := r.db.Exec(ctx,
		`UPDATE users SET display_name=$1, avatar_url=$2, status=$3, bio=$4, updated_at=$5 WHERE id=$6`,
		u.DisplayName, u.AvatarURL, u.Status, u.Bio, u.UpdatedAt, u.ID)
	return err
}

// TeamRepo handles team database operations
type TeamRepo struct {
	db *pgxpool.Pool
}

func (r *TeamRepo) Create(ctx context.Context, t *model.Team) error {
	t.ID = uuid.New()
	t.CreatedAt = time.Now()
	t.UpdatedAt = time.Now()
	_, err := r.db.Exec(ctx,
		`INSERT INTO teams (id, name, slug, description, avatar_url, created_by, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
		t.ID, t.Name, t.Slug, t.Description, t.AvatarURL, t.CreatedBy, t.CreatedAt, t.UpdatedAt)
	return err
}

func (r *TeamRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.Team, error) {
	var t model.Team
	err := r.db.QueryRow(ctx,
		`SELECT t.id, t.name, t.slug, t.description, t.avatar_url, t.created_by, t.created_at, t.updated_at,
		        COUNT(tm.user_id) as member_count
		 FROM teams t
		 LEFT JOIN team_members tm ON t.id = tm.team_id
		 WHERE t.id = $1
		 GROUP BY t.id`, id).
		Scan(&t.ID, &t.Name, &t.Slug, &t.Description, &t.AvatarURL, &t.CreatedBy, &t.CreatedAt, &t.UpdatedAt, &t.MemberCount)
	if err != nil {
		return nil, err
	}
	return &t, nil
}

func (r *TeamRepo) ListByUser(ctx context.Context, userID uuid.UUID) ([]model.Team, error) {
	rows, err := r.db.Query(ctx,
		`SELECT t.id, t.name, t.slug, t.description, t.avatar_url, t.created_by, t.created_at, t.updated_at,
		        COUNT(tm2.user_id) as member_count
		 FROM teams t
		 JOIN team_members tm ON t.id = tm.team_id AND tm.user_id = $1
		 LEFT JOIN team_members tm2 ON t.id = tm2.team_id
		 GROUP BY t.id
		 ORDER BY t.created_at DESC`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var teams []model.Team
	for rows.Next() {
		var t model.Team
		if err := rows.Scan(&t.ID, &t.Name, &t.Slug, &t.Description, &t.AvatarURL, &t.CreatedBy, &t.CreatedAt, &t.UpdatedAt, &t.MemberCount); err != nil {
			return nil, err
		}
		teams = append(teams, t)
	}
	return teams, nil
}

func (r *TeamRepo) Update(ctx context.Context, t *model.Team) error {
	t.UpdatedAt = time.Now()
	_, err := r.db.Exec(ctx,
		`UPDATE teams SET name=$1, slug=$2, description=$3, avatar_url=$4, updated_at=$5 WHERE id=$6`,
		t.Name, t.Slug, t.Description, t.AvatarURL, t.UpdatedAt, t.ID)
	return err
}

func (r *TeamRepo) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.Exec(ctx, `DELETE FROM teams WHERE id = $1`, id)
	return err
}

func (r *TeamRepo) AddMember(ctx context.Context, m *model.TeamMember) error {
	m.JoinedAt = time.Now()
	_, err := r.db.Exec(ctx,
		`INSERT INTO team_members (team_id, user_id, role, joined_at) VALUES ($1, $2, $3, $4)
		 ON CONFLICT (team_id, user_id) DO UPDATE SET role = $3`,
		m.TeamID, m.UserID, m.Role, m.JoinedAt)
	return err
}

func (r *TeamRepo) UpdateMember(ctx context.Context, teamID, userID uuid.UUID, role string) error {
	_, err := r.db.Exec(ctx,
		`UPDATE team_members SET role = $1 WHERE team_id = $2 AND user_id = $3`,
		role, teamID, userID)
	return err
}

func (r *TeamRepo) RemoveMember(ctx context.Context, teamID, userID uuid.UUID) error {
	_, err := r.db.Exec(ctx,
		`DELETE FROM team_members WHERE team_id = $1 AND user_id = $2`,
		teamID, userID)
	return err
}

func (r *TeamRepo) GetMembers(ctx context.Context, teamID uuid.UUID) ([]model.TeamMember, error) {
	rows, err := r.db.Query(ctx,
		`SELECT tm.team_id, tm.user_id, tm.role, tm.joined_at,
		        u.id, u.firebase_uid, u.email, u.display_name, u.avatar_url, u.status, u.bio, u.created_at, u.updated_at
		 FROM team_members tm
		 JOIN users u ON tm.user_id = u.id
		 WHERE tm.team_id = $1
		 ORDER BY tm.joined_at`, teamID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var members []model.TeamMember
	for rows.Next() {
		var m model.TeamMember
		var u model.User
		if err := rows.Scan(&m.TeamID, &m.UserID, &m.Role, &m.JoinedAt,
			&u.ID, &u.FirebaseUID, &u.Email, &u.DisplayName, &u.AvatarURL, &u.Status, &u.Bio, &u.CreatedAt, &u.UpdatedAt); err != nil {
			return nil, err
		}
		m.User = &u
		members = append(members, m)
	}
	return members, nil
}

// ProjectRepo handles project database operations
type ProjectRepo struct {
	db *pgxpool.Pool
}

func (r *ProjectRepo) Create(ctx context.Context, p *model.Project) error {
	p.ID = uuid.New()
	p.CreatedAt = time.Now()
	p.UpdatedAt = time.Now()
	_, err := r.db.Exec(ctx,
		`INSERT INTO projects (id, team_id, name, description, language, repo_url, created_by, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
		p.ID, p.TeamID, p.Name, p.Description, p.Language, p.RepoURL, p.CreatedBy, p.CreatedAt, p.UpdatedAt)
	return err
}

func (r *ProjectRepo) ListByTeam(ctx context.Context, teamID uuid.UUID) ([]model.Project, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, team_id, name, description, language, repo_url, created_by, created_at, updated_at
		 FROM projects WHERE team_id = $1 ORDER BY created_at DESC`, teamID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var projects []model.Project
	for rows.Next() {
		var p model.Project
		if err := rows.Scan(&p.ID, &p.TeamID, &p.Name, &p.Description, &p.Language, &p.RepoURL, &p.CreatedBy, &p.CreatedAt, &p.UpdatedAt); err != nil {
			return nil, err
		}
		projects = append(projects, p)
	}
	return projects, nil
}

// RoomRepo handles room database operations
type RoomRepo struct {
	db *pgxpool.Pool
}

func (r *RoomRepo) Create(ctx context.Context, room *model.Room) error {
	room.ID = uuid.New()
	room.CreatedAt = time.Now()
	room.UpdatedAt = time.Now()
	room.IsActive = true
	_, err := r.db.Exec(ctx,
		`INSERT INTO rooms (id, name, description, language, team_id, project_id, created_by, is_active, content, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
		room.ID, room.Name, room.Description, room.Language, room.TeamID, room.ProjectID,
		room.CreatedBy, room.IsActive, room.Content, room.CreatedAt, room.UpdatedAt)
	return err
}

func (r *RoomRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.Room, error) {
	var room model.Room
	var team model.Team
	err := r.db.QueryRow(ctx,
		`SELECT r.id, r.name, r.description, r.language, r.team_id, r.project_id, r.created_by,
		        r.is_active, r.content, r.created_at, r.updated_at,
		        t.id, t.name, t.slug
		 FROM rooms r
		 JOIN teams t ON r.team_id = t.id
		 WHERE r.id = $1`, id).
		Scan(&room.ID, &room.Name, &room.Description, &room.Language, &room.TeamID, &room.ProjectID,
			&room.CreatedBy, &room.IsActive, &room.Content, &room.CreatedAt, &room.UpdatedAt,
			&team.ID, &team.Name, &team.Slug)
	if err != nil {
		return nil, err
	}
	room.Team = &team
	return &room, nil
}

func (r *RoomRepo) List(ctx context.Context, userID uuid.UUID) ([]model.Room, error) {
	rows, err := r.db.Query(ctx,
		`SELECT r.id, r.name, r.description, r.language, r.team_id, r.project_id, r.created_by,
		        r.is_active, r.created_at, r.updated_at,
		        t.id, t.name, t.slug
		 FROM rooms r
		 JOIN teams t ON r.team_id = t.id
		 JOIN team_members tm ON t.id = tm.team_id AND tm.user_id = $1
		 WHERE r.is_active = true
		 ORDER BY r.updated_at DESC`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var rooms []model.Room
	for rows.Next() {
		var room model.Room
		var team model.Team
		if err := rows.Scan(&room.ID, &room.Name, &room.Description, &room.Language, &room.TeamID, &room.ProjectID,
			&room.CreatedBy, &room.IsActive, &room.CreatedAt, &room.UpdatedAt,
			&team.ID, &team.Name, &team.Slug); err != nil {
			return nil, err
		}
		room.Team = &team
		rooms = append(rooms, room)
	}
	return rooms, nil
}

func (r *RoomRepo) UpdateContent(ctx context.Context, id uuid.UUID, content []byte) error {
	_, err := r.db.Exec(ctx,
		`UPDATE rooms SET content = $1, updated_at = $2 WHERE id = $3`,
		content, time.Now(), id)
	return err
}

func (r *RoomRepo) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.Exec(ctx, `UPDATE rooms SET is_active = false WHERE id = $1`, id)
	return err
}

func (r *RoomRepo) CreateMessage(ctx context.Context, msg *model.RoomMessage) error {
	msg.ID = uuid.New()
	msg.CreatedAt = time.Now()
	_, err := r.db.Exec(ctx,
		`INSERT INTO room_messages (id, room_id, user_id, content, created_at)
		 VALUES ($1, $2, $3, $4, $5)`,
		msg.ID, msg.RoomID, msg.UserID, msg.Content, msg.CreatedAt)
	return err
}

func (r *RoomRepo) ListMessages(ctx context.Context, roomID uuid.UUID, limit int) ([]model.RoomMessage, error) {
	if limit <= 0 {
		limit = 50
	}
	rows, err := r.db.Query(ctx,
		`SELECT m.id, m.room_id, m.user_id, m.content, m.created_at,
		        u.id, u.display_name, u.avatar_url
		 FROM room_messages m
		 JOIN users u ON m.user_id = u.id
		 WHERE m.room_id = $1
		 ORDER BY m.created_at ASC
		 LIMIT $2`, roomID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var messages []model.RoomMessage
	for rows.Next() {
		var msg model.RoomMessage
		var user model.User
		if err := rows.Scan(&msg.ID, &msg.RoomID, &msg.UserID, &msg.Content, &msg.CreatedAt,
			&user.ID, &user.DisplayName, &user.AvatarURL); err != nil {
			return nil, err
		}
		msg.User = &user
		messages = append(messages, msg)
	}
	return messages, nil
}

// DiscussionRepo handles discussion database operations
type DiscussionRepo struct {
	db *pgxpool.Pool
}

func (r *DiscussionRepo) Create(ctx context.Context, d *model.Discussion) error {
	d.ID = uuid.New()
	d.CreatedAt = time.Now()
	d.UpdatedAt = time.Now()
	_, err := r.db.Exec(ctx,
		`INSERT INTO discussions (id, team_id, project_id, title, content, author_id, is_pinned, tags, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
		d.ID, d.TeamID, d.ProjectID, d.Title, d.Content, d.AuthorID, d.IsPinned, d.Tags, d.CreatedAt, d.UpdatedAt)
	return err
}

func (r *DiscussionRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.Discussion, error) {
	var d model.Discussion
	var author model.User
	err := r.db.QueryRow(ctx,
		`SELECT d.id, d.team_id, d.project_id, d.title, d.content, d.author_id, d.is_pinned, d.tags, d.created_at, d.updated_at,
		        u.id, u.display_name, u.avatar_url, u.email,
		        (SELECT COUNT(*) FROM discussion_replies WHERE discussion_id = d.id) as reply_count
		 FROM discussions d
		 JOIN users u ON d.author_id = u.id
		 WHERE d.id = $1`, id).
		Scan(&d.ID, &d.TeamID, &d.ProjectID, &d.Title, &d.Content, &d.AuthorID, &d.IsPinned, &d.Tags, &d.CreatedAt, &d.UpdatedAt,
			&author.ID, &author.DisplayName, &author.AvatarURL, &author.Email, &d.ReplyCount)
	if err != nil {
		return nil, err
	}
	d.Author = &author
	return &d, nil
}

func (r *DiscussionRepo) ListByTeam(ctx context.Context, teamID uuid.UUID) ([]model.Discussion, error) {
	rows, err := r.db.Query(ctx,
		`SELECT d.id, d.team_id, d.project_id, d.title, d.content, d.author_id, d.is_pinned, d.tags, d.created_at, d.updated_at,
		        u.id, u.display_name, u.avatar_url, u.email,
		        (SELECT COUNT(*) FROM discussion_replies WHERE discussion_id = d.id) as reply_count
		 FROM discussions d
		 JOIN users u ON d.author_id = u.id
		 WHERE d.team_id = $1
		 ORDER BY d.is_pinned DESC, d.updated_at DESC`, teamID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var discussions []model.Discussion
	for rows.Next() {
		var d model.Discussion
		var author model.User
		if err := rows.Scan(&d.ID, &d.TeamID, &d.ProjectID, &d.Title, &d.Content, &d.AuthorID, &d.IsPinned, &d.Tags, &d.CreatedAt, &d.UpdatedAt,
			&author.ID, &author.DisplayName, &author.AvatarURL, &author.Email, &d.ReplyCount); err != nil {
			return nil, err
		}
		d.Author = &author
		discussions = append(discussions, d)
	}
	return discussions, nil
}

func (r *DiscussionRepo) Update(ctx context.Context, d *model.Discussion) error {
	d.UpdatedAt = time.Now()
	_, err := r.db.Exec(ctx,
		`UPDATE discussions SET title=$1, content=$2, tags=$3, updated_at=$4 WHERE id=$5`,
		d.Title, d.Content, d.Tags, d.UpdatedAt, d.ID)
	return err
}

func (r *DiscussionRepo) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.Exec(ctx, `DELETE FROM discussions WHERE id = $1`, id)
	return err
}

func (r *DiscussionRepo) TogglePin(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.Exec(ctx, `UPDATE discussions SET is_pinned = NOT is_pinned WHERE id = $1`, id)
	return err
}

func (r *DiscussionRepo) CreateReply(ctx context.Context, reply *model.DiscussionReply) error {
	reply.ID = uuid.New()
	reply.CreatedAt = time.Now()
	reply.UpdatedAt = time.Now()
	_, err := r.db.Exec(ctx,
		`INSERT INTO discussion_replies (id, discussion_id, parent_id, author_id, content, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		reply.ID, reply.DiscussionID, reply.ParentID, reply.AuthorID, reply.Content, reply.CreatedAt, reply.UpdatedAt)
	return err
}

func (r *DiscussionRepo) GetReplies(ctx context.Context, discussionID uuid.UUID) ([]model.DiscussionReply, error) {
	rows, err := r.db.Query(ctx,
		`SELECT dr.id, dr.discussion_id, dr.parent_id, dr.author_id, dr.content, dr.created_at, dr.updated_at,
		        u.id, u.display_name, u.avatar_url, u.email
		 FROM discussion_replies dr
		 JOIN users u ON dr.author_id = u.id
		 WHERE dr.discussion_id = $1
		 ORDER BY dr.created_at`, discussionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var replies []model.DiscussionReply
	for rows.Next() {
		var r model.DiscussionReply
		var author model.User
		if err := rows.Scan(&r.ID, &r.DiscussionID, &r.ParentID, &r.AuthorID, &r.Content, &r.CreatedAt, &r.UpdatedAt,
			&author.ID, &author.DisplayName, &author.AvatarURL, &author.Email); err != nil {
			return nil, err
		}
		r.Author = &author
		replies = append(replies, r)
	}
	return replies, nil
}

func (r *DiscussionRepo) ToggleReaction(ctx context.Context, reaction *model.Reaction) (bool, error) {
	// Try to delete existing reaction
	result, err := r.db.Exec(ctx,
		`DELETE FROM reactions WHERE target_type = $1 AND target_id = $2 AND user_id = $3 AND emoji = $4`,
		reaction.TargetType, reaction.TargetID, reaction.UserID, reaction.Emoji)
	if err != nil {
		return false, err
	}

	if result.RowsAffected() > 0 {
		return false, nil // Removed
	}

	// Insert new reaction
	reaction.ID = uuid.New()
	reaction.CreatedAt = time.Now()
	_, err = r.db.Exec(ctx,
		`INSERT INTO reactions (id, target_type, target_id, user_id, emoji, created_at)
		 VALUES ($1, $2, $3, $4, $5, $6)`,
		reaction.ID, reaction.TargetType, reaction.TargetID, reaction.UserID, reaction.Emoji, reaction.CreatedAt)
	return true, err
}

func (r *DiscussionRepo) GetReactions(ctx context.Context, targetType string, targetID uuid.UUID) ([]model.Reaction, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, target_type, target_id, user_id, emoji, created_at FROM reactions
		 WHERE target_type = $1 AND target_id = $2`, targetType, targetID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var reactions []model.Reaction
	for rows.Next() {
		var r model.Reaction
		if err := rows.Scan(&r.ID, &r.TargetType, &r.TargetID, &r.UserID, &r.Emoji, &r.CreatedAt); err != nil {
			return nil, err
		}
		reactions = append(reactions, r)
	}
	return reactions, nil
}

// DocumentRepo handles document database operations
type DocumentRepo struct {
	db *pgxpool.Pool
}

func (r *DocumentRepo) Create(ctx context.Context, d *model.Document) error {
	d.ID = uuid.New()
	d.CreatedAt = time.Now()
	d.UpdatedAt = time.Now()
	_, err := r.db.Exec(ctx,
		`INSERT INTO documents (id, team_id, parent_id, title, slug, content, author_id, sort_order, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
		d.ID, d.TeamID, d.ParentID, d.Title, d.Slug, d.Content, d.AuthorID, d.SortOrder, d.CreatedAt, d.UpdatedAt)
	return err
}

func (r *DocumentRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.Document, error) {
	var d model.Document
	var author model.User
	err := r.db.QueryRow(ctx,
		`SELECT d.id, d.team_id, d.parent_id, d.title, d.slug, d.content, d.author_id, d.sort_order, d.created_at, d.updated_at,
		        u.id, u.display_name, u.avatar_url
		 FROM documents d
		 JOIN users u ON d.author_id = u.id
		 WHERE d.id = $1`, id).
		Scan(&d.ID, &d.TeamID, &d.ParentID, &d.Title, &d.Slug, &d.Content, &d.AuthorID, &d.SortOrder, &d.CreatedAt, &d.UpdatedAt,
			&author.ID, &author.DisplayName, &author.AvatarURL)
	if err != nil {
		return nil, err
	}
	d.Author = &author
	return &d, nil
}

func (r *DocumentRepo) ListByTeam(ctx context.Context, teamID uuid.UUID) ([]model.Document, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, team_id, parent_id, title, slug, author_id, sort_order, created_at, updated_at
		 FROM documents WHERE team_id = $1 ORDER BY sort_order, title`, teamID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var docs []model.Document
	for rows.Next() {
		var d model.Document
		if err := rows.Scan(&d.ID, &d.TeamID, &d.ParentID, &d.Title, &d.Slug, &d.AuthorID, &d.SortOrder, &d.CreatedAt, &d.UpdatedAt); err != nil {
			return nil, err
		}
		docs = append(docs, d)
	}
	return docs, nil
}

func (r *DocumentRepo) Update(ctx context.Context, d *model.Document) error {
	d.UpdatedAt = time.Now()
	_, err := r.db.Exec(ctx,
		`UPDATE documents SET title=$1, slug=$2, content=$3, parent_id=$4, sort_order=$5, updated_at=$6 WHERE id=$7`,
		d.Title, d.Slug, d.Content, d.ParentID, d.SortOrder, d.UpdatedAt, d.ID)
	return err
}

func (r *DocumentRepo) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.Exec(ctx, `DELETE FROM documents WHERE id = $1`, id)
	return err
}

func (r *DocumentRepo) CreateVersion(ctx context.Context, v *model.DocumentVersion) error {
	v.ID = uuid.New()
	v.CreatedAt = time.Now()

	// Get next version number
	var maxVersion int
	err := r.db.QueryRow(ctx,
		`SELECT COALESCE(MAX(version), 0) FROM document_versions WHERE document_id = $1`, v.DocumentID).
		Scan(&maxVersion)
	if err != nil && err != pgx.ErrNoRows {
		return err
	}
	v.Version = maxVersion + 1

	_, err = r.db.Exec(ctx,
		`INSERT INTO document_versions (id, document_id, title, content, author_id, version, created_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		v.ID, v.DocumentID, v.Title, v.Content, v.AuthorID, v.Version, v.CreatedAt)
	return err
}

func (r *DocumentRepo) GetVersions(ctx context.Context, docID uuid.UUID) ([]model.DocumentVersion, error) {
	rows, err := r.db.Query(ctx,
		`SELECT dv.id, dv.document_id, dv.title, dv.content, dv.author_id, dv.version, dv.created_at,
		        u.id, u.display_name, u.avatar_url
		 FROM document_versions dv
		 JOIN users u ON dv.author_id = u.id
		 WHERE dv.document_id = $1
		 ORDER BY dv.version DESC`, docID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var versions []model.DocumentVersion
	for rows.Next() {
		var v model.DocumentVersion
		var author model.User
		if err := rows.Scan(&v.ID, &v.DocumentID, &v.Title, &v.Content, &v.AuthorID, &v.Version, &v.CreatedAt,
			&author.ID, &author.DisplayName, &author.AvatarURL); err != nil {
			return nil, err
		}
		v.Author = &author
		versions = append(versions, v)
	}
	return versions, nil
}

// ActivityRepo handles activity database operations
type ActivityRepo struct {
	db *pgxpool.Pool
}

func (r *ActivityRepo) Create(ctx context.Context, a *model.Activity) error {
	a.ID = uuid.New()
	a.CreatedAt = time.Now()
	_, err := r.db.Exec(ctx,
		`INSERT INTO activities (id, team_id, actor_id, action, target_type, target_id, target_name, metadata, created_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
		a.ID, a.TeamID, a.ActorID, a.Action, a.TargetType, a.TargetID, a.TargetName, a.Metadata, a.CreatedAt)
	return err
}

func (r *ActivityRepo) List(ctx context.Context, userID uuid.UUID, limit, offset int) ([]model.Activity, error) {
	rows, err := r.db.Query(ctx,
		`SELECT a.id, a.team_id, a.actor_id, a.action, a.target_type, a.target_id, a.target_name, a.metadata, a.created_at,
		        u.id, u.display_name, u.avatar_url
		 FROM activities a
		 JOIN users u ON a.actor_id = u.id
		 JOIN team_members tm ON a.team_id = tm.team_id AND tm.user_id = $1
		 ORDER BY a.created_at DESC
		 LIMIT $2 OFFSET $3`, userID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var activities []model.Activity
	for rows.Next() {
		var a model.Activity
		var actor model.User
		if err := rows.Scan(&a.ID, &a.TeamID, &a.ActorID, &a.Action, &a.TargetType, &a.TargetID, &a.TargetName, &a.Metadata, &a.CreatedAt,
			&actor.ID, &actor.DisplayName, &actor.AvatarURL); err != nil {
			return nil, err
		}
		a.Actor = &actor
		activities = append(activities, a)
	}
	return activities, nil
}

func (r *ActivityRepo) CreateNotification(ctx context.Context, n *model.Notification) error {
	n.ID = uuid.New()
	n.CreatedAt = time.Now()
	_, err := r.db.Exec(ctx,
		`INSERT INTO notifications (id, user_id, type, title, content, link_url, is_read, created_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
		n.ID, n.UserID, n.Type, n.Title, n.Content, n.LinkURL, n.IsRead, n.CreatedAt)
	return err
}

func (r *ActivityRepo) ListNotifications(ctx context.Context, userID uuid.UUID) ([]model.Notification, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, user_id, type, title, content, link_url, is_read, created_at
		 FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var notifications []model.Notification
	for rows.Next() {
		var n model.Notification
		if err := rows.Scan(&n.ID, &n.UserID, &n.Type, &n.Title, &n.Content, &n.LinkURL, &n.IsRead, &n.CreatedAt); err != nil {
			return nil, err
		}
		notifications = append(notifications, n)
	}
	return notifications, nil
}

func (r *ActivityRepo) MarkNotificationRead(ctx context.Context, id, userID uuid.UUID) error {
	_, err := r.db.Exec(ctx,
		`UPDATE notifications SET is_read = true WHERE id = $1 AND user_id = $2`, id, userID)
	return err
}
