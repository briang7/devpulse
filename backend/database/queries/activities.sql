-- name: CreateActivity :one
INSERT INTO activities (team_id, actor_id, action, target_type, target_id, target_name, metadata)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *;

-- name: ListActivitiesByUser :many
SELECT a.*, u.display_name as actor_name, u.avatar_url as actor_avatar
FROM activities a
JOIN users u ON a.actor_id = u.id
JOIN team_members tm ON a.team_id = tm.team_id AND tm.user_id = $1
ORDER BY a.created_at DESC
LIMIT $2 OFFSET $3;

-- name: ListActivitiesByTeam :many
SELECT a.*, u.display_name as actor_name, u.avatar_url as actor_avatar
FROM activities a
JOIN users u ON a.actor_id = u.id
WHERE a.team_id = $1
ORDER BY a.created_at DESC
LIMIT $2 OFFSET $3;

-- name: CreateNotification :one
INSERT INTO notifications (user_id, type, title, content, link_url, is_read)
VALUES ($1, $2, $3, $4, $5, false)
RETURNING *;

-- name: ListNotifications :many
SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50;

-- name: MarkNotificationRead :exec
UPDATE notifications SET is_read = true WHERE id = $1 AND user_id = $2;

-- name: CountUnreadNotifications :one
SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = false;
