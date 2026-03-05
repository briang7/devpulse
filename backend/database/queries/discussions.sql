-- name: CreateDiscussion :one
INSERT INTO discussions (team_id, project_id, title, content, author_id, is_pinned, tags)
VALUES ($1, $2, $3, $4, $5, false, $6)
RETURNING *;

-- name: GetDiscussionByID :one
SELECT d.*, u.display_name as author_name, u.avatar_url as author_avatar, u.email as author_email,
       (SELECT COUNT(*) FROM discussion_replies WHERE discussion_id = d.id) as reply_count
FROM discussions d
JOIN users u ON d.author_id = u.id
WHERE d.id = $1;

-- name: ListDiscussionsByTeam :many
SELECT d.*, u.display_name as author_name, u.avatar_url as author_avatar, u.email as author_email,
       (SELECT COUNT(*) FROM discussion_replies WHERE discussion_id = d.id) as reply_count
FROM discussions d
JOIN users u ON d.author_id = u.id
WHERE d.team_id = $1
ORDER BY d.is_pinned DESC, d.updated_at DESC;

-- name: UpdateDiscussion :exec
UPDATE discussions SET title = $2, content = $3, tags = $4 WHERE id = $1;

-- name: DeleteDiscussion :exec
DELETE FROM discussions WHERE id = $1;

-- name: ToggleDiscussionPin :exec
UPDATE discussions SET is_pinned = NOT is_pinned WHERE id = $1;

-- name: CreateReply :one
INSERT INTO discussion_replies (discussion_id, parent_id, author_id, content)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: ListReplies :many
SELECT dr.*, u.display_name as author_name, u.avatar_url as author_avatar, u.email as author_email
FROM discussion_replies dr
JOIN users u ON dr.author_id = u.id
WHERE dr.discussion_id = $1
ORDER BY dr.created_at;

-- name: ToggleReaction :exec
INSERT INTO reactions (target_type, target_id, user_id, emoji)
VALUES ($1, $2, $3, $4)
ON CONFLICT (target_type, target_id, user_id, emoji) DO NOTHING;

-- name: RemoveReaction :exec
DELETE FROM reactions WHERE target_type = $1 AND target_id = $2 AND user_id = $3 AND emoji = $4;

-- name: GetReactions :many
SELECT * FROM reactions WHERE target_type = $1 AND target_id = $2;
