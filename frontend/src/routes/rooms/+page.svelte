<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { roomsStore, loadRooms, roomsLoading, createRoom } from '$lib/stores/rooms';
  import { teamsStore, loadTeams } from '$lib/stores/teams';
  import { timeAgo, getLanguageColor } from '$lib/utils/format';
  import EmptyState from '$lib/components/shared/EmptyState.svelte';
  import SkeletonLoader from '$lib/components/shared/SkeletonLoader.svelte';
  import Modal from '$lib/components/shared/Modal.svelte';

  let showCreateModal = $state(false);
  let newName = $state('');
  let newDescription = $state('');
  let newLanguage = $state('javascript');
  let newTeamId = $state('');
  let creating = $state(false);

  const languages = ['javascript', 'typescript', 'python', 'go', 'rust'];

  async function handleCreate() {
    if (!newName.trim() || !newTeamId) return;
    creating = true;
    try {
      const room = await createRoom({
        name: newName,
        description: newDescription,
        language: newLanguage,
        teamId: newTeamId
      });
      showCreateModal = false;
      newName = '';
      newDescription = '';
      goto(`/rooms/${room.id}`);
    } catch (e) {
      console.error('Failed to create room', e);
    } finally {
      creating = false;
    }
  }

  onMount(async () => {
    loadRooms();
    await loadTeams();
    if ($teamsStore.length > 0) {
      newTeamId = $teamsStore[0].id;
    }
  });
</script>

<div class="max-w-6xl mx-auto">
  <div class="flex items-center justify-between mb-6">
    <div>
      <h1 class="text-2xl font-bold text-[var(--dp-text)]">Code Rooms</h1>
      <p class="text-[var(--dp-text-muted)] mt-1">Collaborate on code in real-time</p>
    </div>
    <button onclick={() => showCreateModal = true} class="px-4 py-2 rounded-lg bg-violet-600 hover:bg-violet-500 text-white text-sm font-medium transition-colors flex items-center gap-2">
      <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
      </svg>
      New Room
    </button>
  </div>

  {#if $roomsLoading}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {#each Array(6) as _}
        <SkeletonLoader type="card" />
      {/each}
    </div>
  {:else if $roomsStore.length === 0}
    <EmptyState title="No code rooms yet" description="Create your first room to start collaborating on code in real-time." icon="rooms" />
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 stagger-children">
      {#each $roomsStore as room}
        <a
          href="/rooms/{room.id}"
          class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-5 hover:border-violet-500/30 hover-lift group"
        >
          <div class="flex items-start justify-between mb-3">
            <div class="w-10 h-10 rounded-lg flex items-center justify-center" style="background: {getLanguageColor(room.language)}20">
              <svg class="w-5 h-5" style="color: {getLanguageColor(room.language)}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
              </svg>
            </div>
            {#if room.isActive}
              <span class="flex items-center gap-1.5 text-xs text-emerald-400">
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 pulse-glow"></span>
                Live
              </span>
            {/if}
          </div>
          <h3 class="font-semibold text-[var(--dp-text)] group-hover:text-violet-400 transition-colors mb-1">{room.name}</h3>
          <p class="text-sm text-[var(--dp-text-muted)] mb-3 line-clamp-2">{room.description || 'No description'}</p>
          <div class="flex items-center gap-3 text-xs text-[var(--dp-text-muted)]">
            <span class="px-2 py-0.5 rounded-full bg-[var(--dp-bg-surface)]">{room.language}</span>
            <span>{room.team?.name || 'Team'}</span>
            <span>&middot; {timeAgo(room.updatedAt)}</span>
          </div>
        </a>
      {/each}
    </div>
  {/if}
</div>

<Modal bind:open={showCreateModal} title="New Code Room">
  <form onsubmit={(e) => { e.preventDefault(); handleCreate(); }} class="space-y-4">
    <div>
      <label for="room-name" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Room Name</label>
      <input id="room-name" type="text" bind:value={newName} placeholder="e.g. API Refactor Session" required
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50" />
    </div>
    <div>
      <label for="room-desc" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Description</label>
      <textarea id="room-desc" bind:value={newDescription} placeholder="What will you be working on?" rows="2"
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50 resize-none"></textarea>
    </div>
    <div>
      <label for="room-lang" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Language</label>
      <select id="room-lang" bind:value={newLanguage}
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] focus:outline-none focus:ring-2 focus:ring-violet-500/50">
        {#each languages as lang}
          <option value={lang}>{lang.charAt(0).toUpperCase() + lang.slice(1)}</option>
        {/each}
      </select>
    </div>
    <div>
      <label for="room-team" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Team</label>
      <select id="room-team" bind:value={newTeamId}
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] focus:outline-none focus:ring-2 focus:ring-violet-500/50">
        {#each $teamsStore as team}
          <option value={team.id}>{team.name}</option>
        {/each}
      </select>
    </div>
    <div class="mt-5">
      <button type="submit" disabled={creating || !newName.trim()}
        class="w-full py-2.5 rounded-lg bg-violet-600 hover:bg-violet-500 disabled:opacity-50 disabled:cursor-not-allowed text-white text-sm font-medium transition-colors">
        {creating ? 'Creating...' : 'Create Room'}
      </button>
    </div>
  </form>
</Modal>
