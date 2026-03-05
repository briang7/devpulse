-- name: CreateTeam :one
INSERT INTO teams (name, slug, description, avatar_url, created_by)
VALUES ($1, $2, $3, $4, $5)
RETURNING *;

-- name: GetTeamByID :one
SELECT t.*, COUNT(tm.user_id) as member_count
FROM teams t
LEFT JOIN team_members tm ON t.id = tm.team_id
WHERE t.id = $1
GROUP BY t.id;

-- name: ListTeamsByUser :many
SELECT t.*, COUNT(tm2.user_id) as member_count
FROM teams t
JOIN team_members tm ON t.id = tm.team_id AND tm.user_id = $1
LEFT JOIN team_members tm2 ON t.id = tm2.team_id
GROUP BY t.id
ORDER BY t.created_at DESC;

-- name: UpdateTeam :exec
UPDATE teams SET name = $2, slug = $3, description = $4, avatar_url = $5
WHERE id = $1;

-- name: DeleteTeam :exec
DELETE FROM teams WHERE id = $1;

-- name: AddTeamMember :exec
INSERT INTO team_members (team_id, user_id, role)
VALUES ($1, $2, $3)
ON CONFLICT (team_id, user_id) DO UPDATE SET role = $3;

-- name: UpdateTeamMember :exec
UPDATE team_members SET role = $3 WHERE team_id = $1 AND user_id = $2;

-- name: RemoveTeamMember :exec
DELETE FROM team_members WHERE team_id = $1 AND user_id = $2;

-- name: GetTeamMembers :many
SELECT tm.*, u.id as user_id, u.display_name, u.email, u.avatar_url, u.status
FROM team_members tm
JOIN users u ON tm.user_id = u.id
WHERE tm.team_id = $1
ORDER BY tm.joined_at;
