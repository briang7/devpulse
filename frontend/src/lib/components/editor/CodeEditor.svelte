<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { EditorState, type Extension } from '@codemirror/state';
  import { EditorView } from '@codemirror/view';
  import { basicSetup } from 'codemirror';
  import { oneDark } from '@codemirror/theme-one-dark';
  import { javascript } from '@codemirror/lang-javascript';
  import { python } from '@codemirror/lang-python';
  import { go } from '@codemirror/lang-go';
  import { rust } from '@codemirror/lang-rust';

  let {
    language = 'javascript',
    value = '',
    readonly = false,
    view = $bindable(undefined)
  }: {
    language?: string;
    value?: string;
    readonly?: boolean;
    view?: EditorView | undefined;
  } = $props();

  let editorContainer: HTMLDivElement;

  const sampleCode: Record<string, string> = {
    javascript: `import express from 'express';

const app = express();
app.use(express.json());

app.get('/api/users', async (req, res) => {
  try {
    const users = await db.query('SELECT * FROM users');
    res.json({ success: true, data: users });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.post('/api/users', async (req, res) => {
  const { name, email } = req.body;
  const user = await db.query(
    'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',
    [name, email]
  );
  res.status(201).json({ success: true, data: user });
});

app.listen(3000, () => console.log('Server running on port 3000'));`,

    typescript: `import express, { Request, Response } from 'express';

interface User {
  id: number;
  name: string;
  email: string;
}

const app = express();
app.use(express.json());

app.get('/api/users', async (_req: Request, res: Response) => {
  try {
    const users: User[] = await db.query('SELECT * FROM users');
    res.json({ success: true, data: users });
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    res.status(500).json({ success: false, error: message });
  }
});

app.listen(3000, () => console.log('Server running on port 3000'));`,

    python: `from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()


class User(BaseModel):
    name: str
    email: str


class UserResponse(BaseModel):
    id: int
    name: str
    email: str


users_db: list[UserResponse] = []


@app.get("/api/users", response_model=list[UserResponse])
async def get_users():
    return users_db


@app.post("/api/users", response_model=UserResponse, status_code=201)
async def create_user(user: User):
    new_user = UserResponse(id=len(users_db) + 1, **user.model_dump())
    users_db.append(new_user)
    return new_user`,

    go: `package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type User struct {
	ID    int    \`json:"id"\`
	Name  string \`json:"name"\`
	Email string \`json:"email"\`
}

var users []User
var nextID = 1

func getUsers(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(users)
}

func createUser(w http.ResponseWriter, r *http.Request) {
	var user User
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	user.ID = nextID
	nextID++
	users = append(users, user)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(user)
}

func main() {
	http.HandleFunc("/api/users", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case http.MethodGet:
			getUsers(w, r)
		case http.MethodPost:
			createUser(w, r)
		}
	})
	log.Println("Server running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}`,

    rust: `use actix_web::{web, App, HttpServer, HttpResponse, Responder};
use serde::{Deserialize, Serialize};
use std::sync::Mutex;

#[derive(Debug, Serialize, Deserialize, Clone)]
struct User {
    id: u32,
    name: String,
    email: String,
}

#[derive(Debug, Deserialize)]
struct CreateUser {
    name: String,
    email: String,
}

struct AppState {
    users: Mutex<Vec<User>>,
    next_id: Mutex<u32>,
}

async fn get_users(data: web::Data<AppState>) -> impl Responder {
    let users = data.users.lock().unwrap();
    HttpResponse::Ok().json(users.clone())
}

async fn create_user(
    data: web::Data<AppState>,
    body: web::Json<CreateUser>,
) -> impl Responder {
    let mut users = data.users.lock().unwrap();
    let mut next_id = data.next_id.lock().unwrap();
    let user = User { id: *next_id, name: body.name.clone(), email: body.email.clone() };
    *next_id += 1;
    users.push(user.clone());
    HttpResponse::Created().json(user)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let data = web::Data::new(AppState {
        users: Mutex::new(Vec::new()),
        next_id: Mutex::new(1),
    });
    HttpServer::new(move || {
        App::new()
            .app_data(data.clone())
            .route("/api/users", web::get().to(get_users))
            .route("/api/users", web::post().to(create_user))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}`
  };

  function getLanguageExtension(lang: string): Extension {
    switch (lang) {
      case 'typescript':
        return javascript({ typescript: true });
      case 'javascript':
        return javascript();
      case 'python':
        return python();
      case 'go':
        return go();
      case 'rust':
        return rust();
      default:
        return javascript();
    }
  }

  function getInitialDoc(lang: string): string {
    if (value) return value;
    return sampleCode[lang] ?? sampleCode['javascript'];
  }

  function createEditor() {
    if (!editorContainer) return;

    const extensions: Extension[] = [
      basicSetup,
      oneDark,
      getLanguageExtension(language),
      EditorView.theme({
        '&': { height: '100%' },
        '.cm-scroller': { overflow: 'auto' }
      })
    ];

    if (readonly) {
      extensions.push(EditorState.readOnly.of(true));
    }

    const state = EditorState.create({
      doc: getInitialDoc(language),
      extensions
    });

    view = new EditorView({
      state,
      parent: editorContainer
    });
  }

  onMount(() => {
    createEditor();
  });

  onDestroy(() => {
    if (view) {
      view.destroy();
      view = undefined;
    }
  });

  // React to language changes
  let prevLang: string | undefined;
  $effect(() => {
    const lang = language;
    if (!view || lang === prevLang) {
      prevLang = lang;
      return;
    }
    prevLang = lang;

    // Replace content with language-appropriate sample
    const newDoc = getInitialDoc(lang);
    view.dispatch({
      changes: { from: 0, to: view.state.doc.length, insert: newDoc },
      effects: EditorView.reconfigure.of([
        basicSetup,
        oneDark,
        getLanguageExtension(lang),
        EditorView.theme({
          '&': { height: '100%' },
          '.cm-scroller': { overflow: 'auto' }
        }),
        ...(readonly ? [EditorState.readOnly.of(true)] : [])
      ])
    });
  });
</script>

<div class="code-editor-container" bind:this={editorContainer}></div>

<style>
  .code-editor-container {
    height: 100%;
    min-height: 300px;
    overflow: hidden;
    border-radius: 8px;
    border: 1px solid var(--dp-border, rgba(255, 255, 255, 0.08));
  }

  .code-editor-container :global(.cm-editor) {
    height: 100%;
    font-size: 14px;
  }

  .code-editor-container :global(.cm-editor.cm-focused) {
    outline: none;
  }

  .code-editor-container :global(.cm-gutters) {
    border-right: 1px solid rgba(255, 255, 255, 0.06);
  }
</style>
