-- Reverse initial schema
DROP TRIGGER IF EXISTS trg_documents_updated_at ON documents;
DROP TRIGGER IF EXISTS trg_discussion_replies_updated_at ON discussion_replies;
DROP TRIGGER IF EXISTS trg_discussions_updated_at ON discussions;
DROP TRIGGER IF EXISTS trg_rooms_updated_at ON rooms;
DROP TRIGGER IF EXISTS trg_projects_updated_at ON projects;
DROP TRIGGER IF EXISTS trg_teams_updated_at ON teams;
DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
DROP FUNCTION IF EXISTS update_updated_at();

DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS document_versions;
DROP TABLE IF EXISTS documents;
DROP TABLE IF EXISTS reactions;
DROP TABLE IF EXISTS discussion_replies;
DROP TABLE IF EXISTS discussions;
DROP TABLE IF EXISTS room_messages;
DROP TABLE IF EXISTS room_participants;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS team_members;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS users;
