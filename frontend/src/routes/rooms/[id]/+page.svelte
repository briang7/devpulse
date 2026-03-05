<script lang="ts">
  import { onMount, onDestroy, tick } from 'svelte';
  import { page } from '$app/stores';
  import { currentRoom, loadRoom } from '$lib/stores/rooms';
  import { currentUser } from '$lib/stores/auth';
  import { api } from '$lib/services/api';
  import { WebSocketClient } from '$lib/services/websocket';

  interface ChatMessage {
    id?: string;
    name: string;
    content: string;
    time: string;
  }

  interface RemoteCursor {
    userId: string;
    name: string;
    color: string;
    line: number;
    col: number;
  }

  let roomId = $derived($page.params.id);
  let participants = $state<Array<{userId: string; name: string; color: string}>>([]);
  let chatMessages = $state<ChatMessage[]>([]);
  let chatInput = $state('');
  let CodeEditor: any = $state(null);
  let editorView: any = $state(null);
  let saving = $state(false);
  let saved = $state(false);
  let loadedCode = $state('');
  let ws: WebSocketClient | null = null;
  let wsConnected = $state(false);
  let remoteCursors = $state<RemoteCursor[]>([]);
  let chatContainer: HTMLDivElement;

  onMount(async () => {
    const room = await loadRoom(roomId);

    // Load saved code from room content (Go serializes []byte as base64)
    if (room?.content) {
      try {
        const decoded = typeof room.content === 'string'
          ? atob(room.content)
          : new TextDecoder().decode(new Uint8Array(Object.values(room.content as any)));
        if (decoded.trim()) loadedCode = decoded;
      } catch { /* use default */ }
    }

    // Load chat messages from backend
    try {
      const msgs = await api.get<Array<{id: string; content: string; createdAt: string; user?: {displayName: string}}>>(`/api/rooms/${roomId}/messages`);
      chatMessages = (msgs || []).map(m => ({
        id: m.id,
        name: m.user?.displayName || 'Unknown',
        content: m.content,
        time: new Date(m.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      }));
    } catch { /* no messages yet */ }

    // Dynamically import CodeMirror (it accesses DOM)
    const mod = await import('$lib/components/editor/CodeEditor.svelte');
    CodeEditor = mod.default;

    // Add current user as participant
    if ($currentUser) {
      participants = [{
        userId: $currentUser.id,
        name: $currentUser.displayName,
        color: '#7c3aed'
      }];
    }

    // Initialize WebSocket connection
    connectWebSocket();
  });

  function connectWebSocket() {
    ws = new WebSocketClient(roomId);

    ws.on('connected', () => {
      wsConnected = true;
    });

    ws.on('disconnected', () => {
      wsConnected = false;
    });

    // Handle incoming chat messages
    ws.on('chat', (msg: any) => {
      const payload = msg.payload || msg;
      // Don't duplicate our own messages (we already added optimistically)
      if (payload.userId === $currentUser?.id) return;
      chatMessages = [...chatMessages, {
        name: payload.name || payload.userName || 'Unknown',
        content: payload.content || payload.message,
        time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      }];
      scrollChatToBottom();
    });

    // Handle join/leave events
    ws.on('join', (msg: any) => {
      const payload = msg.payload || msg;
      const exists = participants.some(p => p.userId === payload.userId);
      if (!exists) {
        participants = [...participants, {
          userId: payload.userId,
          name: payload.name || payload.userName || 'Unknown',
          color: payload.color || '#2563eb'
        }];
      }
    });

    ws.on('leave', (msg: any) => {
      const payload = msg.payload || msg;
      participants = participants.filter(p => p.userId !== payload.userId);
      remoteCursors = remoteCursors.filter(c => c.userId !== payload.userId);
    });

    // Handle cursor presence
    ws.on('cursor', (msg: any) => {
      const payload = msg.payload || msg;
      if (payload.userId === $currentUser?.id) return;
      const existing = remoteCursors.findIndex(c => c.userId === payload.userId);
      const cursor: RemoteCursor = {
        userId: payload.userId,
        name: payload.name || 'Unknown',
        color: payload.color || '#2563eb',
        line: payload.line,
        col: payload.col
      };
      if (existing >= 0) {
        remoteCursors[existing] = cursor;
        remoteCursors = [...remoteCursors]; // trigger reactivity
      } else {
        remoteCursors = [...remoteCursors, cursor];
      }
    });

    ws.connect();
  }

  async function scrollChatToBottom() {
    await tick();
    if (chatContainer) {
      chatContainer.scrollTop = chatContainer.scrollHeight;
    }
  }

  async function saveCode() {
    if (!editorView || saving) return;
    saving = true;
    try {
      const code = editorView.state.doc.toString();
      await api.put(`/api/rooms/${roomId}/code`, { code });
      saved = true;
      setTimeout(() => saved = false, 2000);
    } catch (e) {
      console.error('Failed to save code', e);
    } finally {
      saving = false;
    }
  }

  function handleKeydown(e: KeyboardEvent) {
    if ((e.ctrlKey || e.metaKey) && e.key === 's') {
      e.preventDefault();
      saveCode();
    }
  }

  // Send cursor position when editor cursor changes
  function handleEditorClick() {
    if (!editorView || !ws || !$currentUser) return;
    const cursor = editorView.state.selection.main.head;
    const line = editorView.state.doc.lineAt(cursor);
    ws.send('cursor', {
      userId: $currentUser.id,
      name: $currentUser.displayName,
      color: '#7c3aed',
      line: line.number,
      col: cursor - line.from
    });
  }

  async function sendChat() {
    if (!chatInput.trim() || !$currentUser) return;
    const content = chatInput;
    chatInput = '';

    // Optimistic update
    const tempMsg: ChatMessage = {
      name: $currentUser.displayName,
      content,
      time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    };
    chatMessages = [...chatMessages, tempMsg];
    scrollChatToBottom();

    // Send via WebSocket for real-time delivery
    ws?.send('chat', {
      userId: $currentUser.id,
      name: $currentUser.displayName,
      content
    });

    // Persist to backend
    try {
      await api.post(`/api/rooms/${roomId}/messages`, { content });
    } catch (e) {
      console.error('Failed to save message', e);
    }
  }

  function handleChatKeydown(e: KeyboardEvent) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendChat();
    }
  }

  onDestroy(() => {
    ws?.disconnect();
    ws = null;
  });
</script>

<svelte:window onkeydown={handleKeydown} />

<!-- svelte-ignore a11y_no_static_element_interactions -->
<div class="flex -m-4 md:-m-6 h-[calc(100vh-4rem)]">
  <!-- Editor area -->
  <div class="flex-1 flex flex-col bg-[var(--dp-bg-dark)]">
    <!-- Toolbar -->
    <div class="h-12 flex items-center justify-between px-4 border-b border-[var(--dp-border)] bg-[var(--dp-bg-card)]">
      <div class="flex items-center gap-3">
        <a href="/rooms" aria-label="Back to rooms" class="text-[var(--dp-text-muted)] hover:text-violet-400 transition-colors">
          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
          </svg>
        </a>
        <h2 class="font-semibold text-[var(--dp-text)]">{$currentRoom?.name || 'Code Room'}</h2>
        <span class="px-2 py-0.5 rounded-full text-xs bg-[var(--dp-bg-surface)] text-[var(--dp-text-muted)]">{$currentRoom?.language || 'javascript'}</span>
        {#if wsConnected}
          <span class="flex items-center gap-1.5 text-xs text-emerald-400">
            <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 pulse-glow"></span>
            Live
          </span>
        {:else}
          <span class="flex items-center gap-1.5 text-xs text-amber-400">
            <span class="w-1.5 h-1.5 rounded-full bg-amber-400"></span>
            Connecting...
          </span>
        {/if}
      </div>
      <div class="flex items-center gap-3">
        <button
          onclick={saveCode}
          disabled={saving}
          class="px-3 py-1.5 rounded-lg text-xs font-medium transition-all duration-200 flex items-center gap-1.5
            {saved ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30' : 'bg-violet-600 hover:bg-violet-500 text-white'}"
        >
          {#if saving}
            <div class="w-3 h-3 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
            Saving...
          {:else if saved}
            <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" />
            </svg>
            Saved
          {:else}
            <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3" />
            </svg>
            Save
          {/if}
        </button>
        <span class="text-[10px] text-[var(--dp-text-muted)] hidden sm:inline">Ctrl+S</span>
        <div class="flex -space-x-2">
          {#each participants.slice(0, 5) as p}
            <div class="w-7 h-7 rounded-full border-2 border-[var(--dp-bg-card)] flex items-center justify-center text-[10px] text-white font-bold" style="background: {p.color}" title={p.name}>
              {p.name[0]}
            </div>
          {/each}
        </div>
        <span class="text-xs text-[var(--dp-text-muted)]">{participants.length} online</span>
      </div>
    </div>

    <!-- Code editor -->
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <div class="flex-1 overflow-hidden p-2 relative" onclick={handleEditorClick}>
      {#if CodeEditor}
        <CodeEditor
          language={$currentRoom?.language || 'javascript'}
          value={loadedCode || '// Start coding here...\n'}
          bind:view={editorView}
        />
        <!-- Remote cursor overlays -->
        {#each remoteCursors as cursor}
          <div
            class="absolute pointer-events-none z-10 transition-all duration-150"
            style="top: {(cursor.line - 1) * 22 + 48}px; left: {cursor.col * 8.4 + 60}px"
          >
            <div class="w-0.5 h-5 rounded-full" style="background: {cursor.color}"></div>
            <div class="px-1.5 py-0.5 rounded text-[9px] font-medium text-white whitespace-nowrap -mt-0.5" style="background: {cursor.color}">
              {cursor.name}
            </div>
          </div>
        {/each}
      {:else}
        <div class="h-full rounded-lg bg-[var(--dp-bg-card)] border border-[var(--dp-border)] flex items-center justify-center">
          <div class="flex items-center gap-3 text-[var(--dp-text-muted)]">
            <div class="w-5 h-5 border-2 border-violet-500 border-t-transparent rounded-full animate-spin"></div>
            Loading editor...
          </div>
        </div>
      {/if}
    </div>
  </div>

  <!-- Right sidebar: chat + participants -->
  <div class="w-80 border-l border-[var(--dp-border)] bg-[var(--dp-bg-card)] flex flex-col animate-slide-in-right">
    <!-- Participants -->
    <div class="p-4 border-b border-[var(--dp-border)]">
      <h3 class="text-sm font-semibold text-[var(--dp-text)] mb-3">Participants ({participants.length})</h3>
      {#if participants.length === 0}
        <p class="text-xs text-[var(--dp-text-muted)]">Connect to see participants</p>
      {:else}
        <div class="space-y-2">
          {#each participants as p}
            <div class="flex items-center gap-2">
              <div class="w-6 h-6 rounded-full flex items-center justify-center text-[10px] text-white font-bold" style="background: {p.color}">
                {p.name[0]}
              </div>
              <span class="text-sm text-[var(--dp-text)]">{p.name}</span>
              <span class="ml-auto w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
            </div>
          {/each}
        </div>
      {/if}
    </div>

    <!-- Chat -->
    <div class="flex-1 flex flex-col min-h-0">
      <div class="p-4 border-b border-[var(--dp-border)]">
        <h3 class="text-sm font-semibold text-[var(--dp-text)]">Room Chat</h3>
      </div>
      <div class="flex-1 overflow-y-auto p-4 space-y-3" bind:this={chatContainer}>
        {#each chatMessages as msg}
          <div class="animate-fade-in-up">
            <div class="flex items-center gap-1.5 mb-0.5">
              <span class="text-xs font-medium text-violet-400">{msg.name}</span>
              <span class="text-[10px] text-[var(--dp-text-muted)]">{msg.time}</span>
            </div>
            <p class="text-sm text-[var(--dp-text)]">{msg.content}</p>
          </div>
        {/each}
        {#if chatMessages.length === 0}
          <p class="text-xs text-[var(--dp-text-muted)] text-center py-8">No messages yet. Start typing below.</p>
        {/if}
      </div>
      <div class="p-3 border-t border-[var(--dp-border)]">
        <input
          type="text"
          bind:value={chatInput}
          onkeydown={handleChatKeydown}
          placeholder="Type a message..."
          class="w-full px-3 py-2 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50"
        />
      </div>
    </div>
  </div>
</div>
