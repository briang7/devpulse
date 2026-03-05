<script lang="ts">
  import { fly, fade } from 'svelte/transition';
  import { goto } from '$app/navigation';
  import { currentUser, logout } from '$stores/auth';
  import { timeAgo } from '$utils/format';
  import { unreadCount, notificationsStore, markAsRead } from '$stores/activities';
  import { roomsStore } from '$stores/rooms';
  import { teamsStore } from '$stores/teams';
  import { discussionsStore } from '$stores/discussions';
  import { documentsStore } from '$stores/documents';
  import Avatar from '$components/shared/Avatar.svelte';

  let { sidebarCollapsed = false, onMobileMenuToggle = () => {} } = $props();
  let showUserMenu = $state(false);
  let showNotifications = $state(false);
  let query = $state('');
  let searchFocused = $state(false);
  let searchInput: HTMLInputElement;
  let selectedIndex = $state(-1);

  interface SearchResult {
    type: 'room' | 'team' | 'discussion' | 'document';
    label: string;
    id: string;
    href: string;
    detail: string;
    icon: string;
  }

  const typeIcons: Record<string, string> = {
    room: 'M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4',
    team: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z',
    discussion: 'M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z',
    document: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z'
  };

  const typeColors: Record<string, string> = {
    room: 'text-blue-400',
    team: 'text-violet-400',
    discussion: 'text-amber-400',
    document: 'text-emerald-400'
  };

  let results = $derived.by(() => {
    const q = query.trim().toLowerCase();
    if (q.length < 2) return [];

    const matches: SearchResult[] = [];

    for (const room of $roomsStore) {
      if (room.name.toLowerCase().includes(q) || room.description?.toLowerCase().includes(q)) {
        matches.push({
          type: 'room', label: room.name, id: room.id,
          href: `/rooms/${room.id}`,
          detail: `${room.language} · ${room.team?.name || 'Room'}`,
          icon: typeIcons.room
        });
      }
    }

    for (const team of $teamsStore) {
      if (team.name.toLowerCase().includes(q) || team.slug.toLowerCase().includes(q)) {
        matches.push({
          type: 'team', label: team.name, id: team.id,
          href: `/teams/${team.id}`,
          detail: `${team.memberCount} members`,
          icon: typeIcons.team
        });
      }
    }

    for (const disc of $discussionsStore) {
      if (disc.title.toLowerCase().includes(q) || disc.content.toLowerCase().includes(q)) {
        matches.push({
          type: 'discussion', label: disc.title, id: disc.id,
          href: `/discussions/${disc.id}`,
          detail: `${disc.replyCount} replies · ${disc.author?.displayName || ''}`,
          icon: typeIcons.discussion
        });
      }
    }

    for (const doc of $documentsStore) {
      if (doc.title.toLowerCase().includes(q) || doc.content?.toLowerCase().includes(q)) {
        matches.push({
          type: 'document', label: doc.title, id: doc.id,
          href: `/docs/${doc.id}`,
          detail: doc.author?.displayName || 'Document',
          icon: typeIcons.document
        });
      }
    }

    return matches.slice(0, 8);
  });

  function handleSearchKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape') {
      query = '';
      searchInput?.blur();
      return;
    }
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      selectedIndex = Math.min(selectedIndex + 1, results.length - 1);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      selectedIndex = Math.max(selectedIndex - 1, -1);
    } else if (e.key === 'Enter' && selectedIndex >= 0 && results[selectedIndex]) {
      e.preventDefault();
      navigateTo(results[selectedIndex].href);
    }
  }

  function navigateTo(href: string) {
    query = '';
    searchInput?.blur();
    goto(href);
  }

  function handleGlobalKeydown(e: KeyboardEvent) {
    if (e.key === 'k' && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      searchInput?.focus();
    }
  }

  // Reset selection when query changes
  $effect(() => {
    query;
    selectedIndex = -1;
  });
</script>

<svelte:window onkeydown={handleGlobalKeydown} />

<header
  class="fixed top-0 right-0 h-16 z-30 flex items-center justify-between px-4 md:px-6 border-b border-[var(--dp-border)] bg-[var(--dp-bg-card)]/80 backdrop-blur-md transition-all duration-300"
  style="left: {sidebarCollapsed ? '4.5rem' : '16rem'}"
>
  <div class="flex items-center gap-3">
    <!-- Mobile menu button -->
    <button
      onclick={onMobileMenuToggle}
      aria-label="Toggle menu"
      class="md:hidden p-2 rounded-lg text-[var(--dp-text-muted)] hover:bg-white/5 hover:text-[var(--dp-text)] transition-colors"
    >
      <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
      </svg>
    </button>

    <!-- Search -->
    <div class="relative w-48 sm:w-64 md:w-96">
      <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--dp-text-muted)]" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />
      </svg>
      <input
        bind:this={searchInput}
        bind:value={query}
        onfocus={() => searchFocused = true}
        onblur={() => setTimeout(() => searchFocused = false, 200)}
        onkeydown={handleSearchKeydown}
        type="text"
        placeholder="Search rooms, discussions, docs..."
        class="w-full pl-10 pr-4 py-2 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50 focus:border-violet-500/50 transition-colors"
      />
      {#if !searchFocused || query.length === 0}
        <kbd class="absolute right-3 top-1/2 -translate-y-1/2 px-1.5 py-0.5 text-[10px] font-mono text-[var(--dp-text-muted)] bg-[var(--dp-bg-surface)] rounded border border-[var(--dp-border)] hidden sm:block">⌘K</kbd>
      {/if}

      <!-- Search results dropdown -->
      {#if searchFocused && query.length >= 2}
        <div
          transition:fly={{ y: -4, duration: 150 }}
          class="absolute left-0 right-0 top-full mt-2 rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] shadow-2xl overflow-hidden z-50"
        >
          {#if results.length === 0}
            <div class="px-4 py-6 text-center">
              <p class="text-sm text-[var(--dp-text-muted)]">No results for "{query}"</p>
            </div>
          {:else}
            <div class="py-1.5 max-h-80 overflow-y-auto">
              {#each results as result, i}
                <!-- svelte-ignore a11y_no_static_element_interactions -->
                <div
                  class="flex items-center gap-3 px-4 py-2.5 cursor-pointer transition-colors
                    {i === selectedIndex ? 'bg-violet-500/10' : 'hover:bg-white/5'}"
                  onmouseenter={() => selectedIndex = i}
                  onmousedown={() => navigateTo(result.href)}
                >
                  <div class="w-8 h-8 rounded-lg bg-[var(--dp-bg-surface)] flex items-center justify-center shrink-0">
                    <svg class="w-4 h-4 {typeColors[result.type]}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                      <path stroke-linecap="round" stroke-linejoin="round" d={result.icon} />
                    </svg>
                  </div>
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-[var(--dp-text)] truncate">{result.label}</p>
                    <p class="text-xs text-[var(--dp-text-muted)] truncate">{result.detail}</p>
                  </div>
                  <span class="text-[10px] uppercase tracking-wider text-[var(--dp-text-muted)] shrink-0 {typeColors[result.type]}">{result.type}</span>
                </div>
              {/each}
            </div>
            <div class="px-4 py-2 border-t border-[var(--dp-border)] flex items-center gap-3 text-[10px] text-[var(--dp-text-muted)]">
              <span class="flex items-center gap-1"><kbd class="px-1 py-0.5 rounded bg-[var(--dp-bg-surface)] border border-[var(--dp-border)] font-mono">↑↓</kbd> navigate</span>
              <span class="flex items-center gap-1"><kbd class="px-1 py-0.5 rounded bg-[var(--dp-bg-surface)] border border-[var(--dp-border)] font-mono">↵</kbd> open</span>
              <span class="flex items-center gap-1"><kbd class="px-1 py-0.5 rounded bg-[var(--dp-bg-surface)] border border-[var(--dp-border)] font-mono">esc</kbd> close</span>
            </div>
          {/if}
        </div>
      {/if}
    </div>
  </div>

  <!-- Right side -->
  <div class="flex items-center gap-3 md:gap-4">
    <!-- Notifications -->
    <div class="relative">
      <button
        onclick={() => { showNotifications = !showNotifications; showUserMenu = false; }}
        class="relative p-2 rounded-lg text-[var(--dp-text-muted)] hover:bg-white/5 hover:text-[var(--dp-text)] transition-colors"
      >
        <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 005.454-1.31A8.967 8.967 0 0118 9.75V9A6 6 0 006 9v.75a8.967 8.967 0 01-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 01-5.714 0m5.714 0a3 3 0 11-5.714 0" />
        </svg>
        {#if $unreadCount > 0}
          <span class="absolute -top-0.5 -right-0.5 w-4 h-4 flex items-center justify-center text-[10px] font-bold text-white bg-red-500 rounded-full animate-scale-in">
            {$unreadCount > 9 ? '9+' : $unreadCount}
          </span>
        {/if}
      </button>

      {#if showNotifications}
        <div
          transition:fly={{ y: -8, duration: 200 }}
          class="absolute right-0 top-full mt-2 w-80 rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] shadow-xl z-50"
        >
          <div class="px-4 py-2.5 border-b border-[var(--dp-border)] flex items-center justify-between">
            <p class="text-sm font-medium text-[var(--dp-text)]">Notifications</p>
            {#if $unreadCount > 0}
              <span class="text-[10px] text-violet-400 font-medium">{$unreadCount} unread</span>
            {/if}
          </div>
          {#if $notificationsStore.length === 0}
            <div class="px-4 py-8 text-center">
              <svg class="w-8 h-8 mx-auto mb-2 text-[var(--dp-text-muted)] opacity-40" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 005.454-1.31A8.967 8.967 0 0118 9.75V9A6 6 0 006 9v.75a8.967 8.967 0 01-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 01-5.714 0m5.714 0a3 3 0 11-5.714 0" />
              </svg>
              <p class="text-sm text-[var(--dp-text-muted)]">No notifications yet</p>
            </div>
          {:else}
            <div class="max-h-80 overflow-y-auto py-1">
              {#each $notificationsStore.slice(0, 10) as notification}
                <!-- svelte-ignore a11y_no_static_element_interactions -->
                <div
                  class="flex items-start gap-3 px-4 py-3 cursor-pointer transition-colors hover:bg-white/5
                    {notification.isRead ? 'opacity-60' : ''}"
                  onmousedown={() => {
                    if (!notification.isRead) markAsRead(notification.id);
                    if (notification.linkUrl) { showNotifications = false; goto(notification.linkUrl); }
                  }}
                >
                  <div class="w-8 h-8 rounded-lg flex items-center justify-center shrink-0 mt-0.5
                    {notification.type === 'mention' ? 'bg-blue-500/10' : notification.type === 'reply' ? 'bg-violet-500/10' : 'bg-amber-500/10'}">
                    <svg class="w-4 h-4 {notification.type === 'mention' ? 'text-blue-400' : notification.type === 'reply' ? 'text-violet-400' : 'text-amber-400'}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                      {#if notification.type === 'mention'}
                        <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 12a4.5 4.5 0 11-9 0 4.5 4.5 0 019 0zm0 0c0 1.657 1.007 3 2.25 3S21 13.657 21 12a9 9 0 10-2.636 6.364M16.5 12V8.25" />
                      {:else if notification.type === 'reply'}
                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                      {:else}
                        <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 005.454-1.31A8.967 8.967 0 0118 9.75V9A6 6 0 006 9v.75a8.967 8.967 0 01-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 01-5.714 0m5.714 0a3 3 0 11-5.714 0" />
                      {/if}
                    </svg>
                  </div>
                  <div class="min-w-0 flex-1">
                    <p class="text-sm font-medium text-[var(--dp-text)] truncate">{notification.title}</p>
                    <p class="text-xs text-[var(--dp-text-muted)] truncate mt-0.5">{notification.content}</p>
                    <p class="text-[10px] text-[var(--dp-text-muted)] mt-1">{timeAgo(notification.createdAt)}</p>
                  </div>
                  {#if !notification.isRead}
                    <span class="w-2 h-2 rounded-full bg-violet-500 shrink-0 mt-2"></span>
                  {/if}
                </div>
              {/each}
            </div>
          {/if}
        </div>
      {/if}
    </div>

    <!-- User menu -->
    {#if $currentUser}
      <div class="relative">
        <button
          onclick={() => { showUserMenu = !showUserMenu; showNotifications = false; }}
          class="flex items-center gap-2 px-2 py-1.5 rounded-lg hover:bg-white/5 transition-colors"
        >
          <Avatar name={$currentUser.displayName} size="sm" />
          <span class="text-sm font-medium text-[var(--dp-text)] hidden sm:inline">{$currentUser.displayName}</span>
          <svg class="w-4 h-4 text-[var(--dp-text-muted)] transition-transform duration-200 {showUserMenu ? 'rotate-180' : ''}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 8.25l-7.5 7.5-7.5-7.5" />
          </svg>
        </button>

        {#if showUserMenu}
          <div
            transition:fly={{ y: -8, duration: 200 }}
            class="absolute right-0 top-full mt-2 w-56 rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] shadow-xl py-2 z-50"
          >
            <div class="px-4 py-2 border-b border-[var(--dp-border)]">
              <p class="text-sm font-medium text-[var(--dp-text)]">{$currentUser.displayName}</p>
              <p class="text-xs text-[var(--dp-text-muted)]">{$currentUser.email}</p>
            </div>
            <a href="/settings" class="block px-4 py-2 text-sm text-[var(--dp-text-muted)] hover:bg-white/5 hover:text-[var(--dp-text)] transition-colors">Settings</a>
            <button
              onclick={() => { logout(); showUserMenu = false; }}
              class="w-full text-left px-4 py-2 text-sm text-red-400 hover:bg-white/5 transition-colors"
            >
              Sign out
            </button>
          </div>
        {/if}
      </div>
    {/if}
  </div>
</header>

<style>
  /* Mobile: header spans full width */
  @media (max-width: 767px) {
    header {
      left: 0 !important;
    }
  }
</style>
