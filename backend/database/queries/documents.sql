-- name: CreateDocument :one
INSERT INTO documents (team_id, parent_id, title, slug, content, author_id, sort_order)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *;

-- name: GetDocumentByID :one
SELECT d.*, u.display_name as author_name, u.avatar_url as author_avatar
FROM documents d
JOIN users u ON d.author_id = u.id
WHERE d.id = $1;

-- name: GetDocumentBySlug :one
SELECT d.*, u.display_name as author_name, u.avatar_url as author_avatar
FROM documents d
JOIN users u ON d.author_id = u.id
WHERE d.team_id = $1 AND d.slug = $2;

-- name: ListDocumentsByTeam :many
SELECT id, team_id, parent_id, title, slug, author_id, sort_order, created_at, updated_at
FROM documents WHERE team_id = $1 ORDER BY sort_order, title;

-- name: UpdateDocument :exec
UPDATE documents SET title = $2, slug = $3, content = $4, parent_id = $5, sort_order = $6
WHERE id = $1;

-- name: DeleteDocument :exec
DELETE FROM documents WHERE id = $1;

-- name: CreateDocumentVersion :one
INSERT INTO document_versions (document_id, title, content, author_id, version)
VALUES ($1, $2, $3, $4, (SELECT COALESCE(MAX(version), 0) + 1 FROM document_versions WHERE document_id = $1))
RETURNING *;

-- name: ListDocumentVersions :many
SELECT dv.*, u.display_name as author_name, u.avatar_url as author_avatar
FROM document_versions dv
JOIN users u ON dv.author_id = u.id
WHERE dv.document_id = $1
ORDER BY dv.version DESC;
