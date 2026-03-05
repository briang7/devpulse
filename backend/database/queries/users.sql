-- name: GetUserByFirebaseUID :one
SELECT * FROM users WHERE firebase_uid = $1;

-- name: GetUserByID :one
SELECT * FROM users WHERE id = $1;

-- name: GetUserByEmail :one
SELECT * FROM users WHERE email = $1;

-- name: CreateUser :one
INSERT INTO users (firebase_uid, email, display_name, avatar_url, status, bio)
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING *;

-- name: UpdateUser :exec
UPDATE users SET display_name = $2, avatar_url = $3, status = $4, bio = $5
WHERE id = $1;

-- name: ListUsers :many
SELECT * FROM users ORDER BY display_name LIMIT $1 OFFSET $2;
