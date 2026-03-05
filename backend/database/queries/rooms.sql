-- name: CreateRoom :one
INSERT INTO rooms (name, description, language, team_id, project_id, created_by, is_active, content)
VALUES ($1, $2, $3, $4, $5, $6, true, $7)
RETURNING *;

-- name: GetRoomByID :one
SELECT r.*, t.name as team_name, t.slug as team_slug
FROM rooms r
JOIN teams t ON r.team_id = t.id
WHERE r.id = $1;

-- name: ListRoomsByUser :many
SELECT r.*, t.name as team_name, t.slug as team_slug
FROM rooms r
JOIN teams t ON r.team_id = t.id
JOIN team_members tm ON t.id = tm.team_id AND tm.user_id = $1
WHERE r.is_active = true
ORDER BY r.updated_at DESC;

-- name: UpdateRoomContent :exec
UPDATE rooms SET content = $2 WHERE id = $1;

-- name: DeactivateRoom :exec
UPDATE rooms SET is_active = false WHERE id = $1;

-- name: CreateRoomMessage :one
INSERT INTO room_messages (room_id, user_id, content)
VALUES ($1, $2, $3)
RETURNING *;

-- name: ListRoomMessages :many
SELECT rm.*, u.display_name, u.avatar_url
FROM room_messages rm
JOIN users u ON rm.user_id = u.id
WHERE rm.room_id = $1
ORDER BY rm.created_at DESC
LIMIT $2 OFFSET $3;
