package service

import (
	"context"

	"github.com/briang7/devpulse/internal/model"
	"github.com/briang7/devpulse/internal/repository"
	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
)

type Services struct {
	Users       *UserService
	Teams       *TeamService
	Projects    *ProjectService
	Rooms       *RoomService
	Discussions *DiscussionService
	Documents   *DocumentService
	Activities  *ActivityService
}

func NewServices(repos *repository.Repositories, rdb *redis.Client) *Services {
	actSvc := &ActivityService{repo: repos.Activities, redis: rdb}
	return &Services{
		Users:       &UserService{repo: repos.Users},
		Teams:       &TeamService{repo: repos.Teams, activities: actSvc},
		Projects:    &ProjectService{repo: repos.Projects, activities: actSvc},
		Rooms:       &RoomService{repo: repos.Rooms, activities: actSvc},
		Discussions: &DiscussionService{repo: repos.Discussions, activities: actSvc},
		Documents:   &DocumentService{repo: repos.Documents, activities: actSvc},
		Activities:  actSvc,
	}
}

type UserService struct {
	repo *repository.UserRepo
}

func (s *UserService) GetByFirebaseUID(ctx context.Context, uid string) (*model.User, error) {
	return s.repo.GetByFirebaseUID(ctx, uid)
}

func (s *UserService) GetByID(ctx context.Context, id uuid.UUID) (*model.User, error) {
	return s.repo.GetByID(ctx, id)
}

func (s *UserService) Create(ctx context.Context, u *model.User) error {
	return s.repo.Create(ctx, u)
}

type TeamService struct {
	repo       *repository.TeamRepo
	activities *ActivityService
}

func (s *TeamService) Create(ctx context.Context, t *model.Team, userID uuid.UUID) error {
	if err := s.repo.Create(ctx, t); err != nil {
		return err
	}
	// Add creator as owner
	member := &model.TeamMember{TeamID: t.ID, UserID: userID, Role: "owner"}
	if err := s.repo.AddMember(ctx, member); err != nil {
		return err
	}
	s.activities.Record(ctx, t.ID, userID, "created", "team", t.ID, t.Name)
	return nil
}

func (s *TeamService) GetByID(ctx context.Context, id uuid.UUID) (*model.Team, error) {
	return s.repo.GetByID(ctx, id)
}

func (s *TeamService) ListByUser(ctx context.Context, userID uuid.UUID) ([]model.Team, error) {
	return s.repo.ListByUser(ctx, userID)
}

func (s *TeamService) Update(ctx context.Context, t *model.Team) error {
	return s.repo.Update(ctx, t)
}

func (s *TeamService) Delete(ctx context.Context, id uuid.UUID) error {
	return s.repo.Delete(ctx, id)
}

func (s *TeamService) AddMember(ctx context.Context, m *model.TeamMember) error {
	return s.repo.AddMember(ctx, m)
}

func (s *TeamService) UpdateMember(ctx context.Context, teamID, userID uuid.UUID, role string) error {
	return s.repo.UpdateMember(ctx, teamID, userID, role)
}

func (s *TeamService) RemoveMember(ctx context.Context, teamID, userID uuid.UUID) error {
	return s.repo.RemoveMember(ctx, teamID, userID)
}

func (s *TeamService) GetMembers(ctx context.Context, teamID uuid.UUID) ([]model.TeamMember, error) {
	return s.repo.GetMembers(ctx, teamID)
}

type ProjectService struct {
	repo       *repository.ProjectRepo
	activities *ActivityService
}

func (s *ProjectService) Create(ctx context.Context, p *model.Project) error {
	if err := s.repo.Create(ctx, p); err != nil {
		return err
	}
	s.activities.Record(ctx, p.TeamID, p.CreatedBy, "created", "project", p.ID, p.Name)
	return nil
}

func (s *ProjectService) ListByTeam(ctx context.Context, teamID uuid.UUID) ([]model.Project, error) {
	return s.repo.ListByTeam(ctx, teamID)
}

type RoomService struct {
	repo       *repository.RoomRepo
	activities *ActivityService
}

func (s *RoomService) Create(ctx context.Context, room *model.Room) error {
	if err := s.repo.Create(ctx, room); err != nil {
		return err
	}
	s.activities.Record(ctx, room.TeamID, room.CreatedBy, "created", "room", room.ID, room.Name)
	return nil
}

func (s *RoomService) GetByID(ctx context.Context, id uuid.UUID) (*model.Room, error) {
	return s.repo.GetByID(ctx, id)
}

func (s *RoomService) List(ctx context.Context, userID uuid.UUID) ([]model.Room, error) {
	return s.repo.List(ctx, userID)
}

func (s *RoomService) UpdateContent(ctx context.Context, id uuid.UUID, content []byte) error {
	return s.repo.UpdateContent(ctx, id, content)
}

func (s *RoomService) Delete(ctx context.Context, id uuid.UUID) error {
	return s.repo.Delete(ctx, id)
}

func (s *RoomService) CreateMessage(ctx context.Context, msg *model.RoomMessage) error {
	return s.repo.CreateMessage(ctx, msg)
}

func (s *RoomService) ListMessages(ctx context.Context, roomID uuid.UUID, limit int) ([]model.RoomMessage, error) {
	return s.repo.ListMessages(ctx, roomID, limit)
}

type DiscussionService struct {
	repo       *repository.DiscussionRepo
	activities *ActivityService
}

func (s *DiscussionService) Create(ctx context.Context, d *model.Discussion) error {
	if err := s.repo.Create(ctx, d); err != nil {
		return err
	}
	s.activities.Record(ctx, d.TeamID, d.AuthorID, "posted", "discussion", d.ID, d.Title)
	return nil
}

func (s *DiscussionService) GetByID(ctx context.Context, id uuid.UUID) (*model.Discussion, error) {
	return s.repo.GetByID(ctx, id)
}

func (s *DiscussionService) ListByTeam(ctx context.Context, teamID uuid.UUID) ([]model.Discussion, error) {
	return s.repo.ListByTeam(ctx, teamID)
}

func (s *DiscussionService) Update(ctx context.Context, d *model.Discussion) error {
	return s.repo.Update(ctx, d)
}

func (s *DiscussionService) Delete(ctx context.Context, id uuid.UUID) error {
	return s.repo.Delete(ctx, id)
}

func (s *DiscussionService) TogglePin(ctx context.Context, id uuid.UUID) error {
	return s.repo.TogglePin(ctx, id)
}

func (s *DiscussionService) CreateReply(ctx context.Context, reply *model.DiscussionReply) error {
	if err := s.repo.CreateReply(ctx, reply); err != nil {
		return err
	}
	return nil
}

func (s *DiscussionService) GetReplies(ctx context.Context, discussionID uuid.UUID) ([]model.DiscussionReply, error) {
	return s.repo.GetReplies(ctx, discussionID)
}

func (s *DiscussionService) ToggleReaction(ctx context.Context, reaction *model.Reaction) (bool, error) {
	return s.repo.ToggleReaction(ctx, reaction)
}

func (s *DiscussionService) GetReactions(ctx context.Context, targetType string, targetID uuid.UUID) ([]model.Reaction, error) {
	return s.repo.GetReactions(ctx, targetType, targetID)
}

type DocumentService struct {
	repo       *repository.DocumentRepo
	activities *ActivityService
}

func (s *DocumentService) Create(ctx context.Context, d *model.Document) error {
	if err := s.repo.Create(ctx, d); err != nil {
		return err
	}
	s.activities.Record(ctx, d.TeamID, d.AuthorID, "created", "document", d.ID, d.Title)
	return nil
}

func (s *DocumentService) GetByID(ctx context.Context, id uuid.UUID) (*model.Document, error) {
	return s.repo.GetByID(ctx, id)
}

func (s *DocumentService) ListByTeam(ctx context.Context, teamID uuid.UUID) ([]model.Document, error) {
	return s.repo.ListByTeam(ctx, teamID)
}

func (s *DocumentService) Update(ctx context.Context, d *model.Document) error {
	return s.repo.Update(ctx, d)
}

func (s *DocumentService) Delete(ctx context.Context, id uuid.UUID) error {
	return s.repo.Delete(ctx, id)
}

func (s *DocumentService) CreateVersion(ctx context.Context, v *model.DocumentVersion) error {
	return s.repo.CreateVersion(ctx, v)
}

func (s *DocumentService) GetVersions(ctx context.Context, docID uuid.UUID) ([]model.DocumentVersion, error) {
	return s.repo.GetVersions(ctx, docID)
}

type ActivityService struct {
	repo  *repository.ActivityRepo
	redis *redis.Client
}

func (s *ActivityService) Record(ctx context.Context, teamID, actorID uuid.UUID, action, targetType string, targetID uuid.UUID, targetName string) {
	a := &model.Activity{
		TeamID:     teamID,
		ActorID:    actorID,
		Action:     action,
		TargetType: targetType,
		TargetID:   targetID,
		TargetName: targetName,
		Metadata:   "{}",
	}
	_ = s.repo.Create(ctx, a)
	// Publish to Redis for real-time updates (skip if Redis unavailable)
	if s.redis != nil {
		s.redis.Publish(ctx, "activities:"+teamID.String(), a.ID.String())
	}
}

func (s *ActivityService) List(ctx context.Context, userID uuid.UUID, limit, offset int) ([]model.Activity, error) {
	return s.repo.List(ctx, userID, limit, offset)
}

func (s *ActivityService) ListNotifications(ctx context.Context, userID uuid.UUID) ([]model.Notification, error) {
	return s.repo.ListNotifications(ctx, userID)
}

func (s *ActivityService) MarkRead(ctx context.Context, id, userID uuid.UUID) error {
	return s.repo.MarkNotificationRead(ctx, id, userID)
}
