<script lang="ts">
  import { onMount } from 'svelte';
  import { teamsStore, loadTeams, teamsLoading } from '$lib/stores/teams';
  import EmptyState from '$lib/components/shared/EmptyState.svelte';
  import SkeletonLoader from '$lib/components/shared/SkeletonLoader.svelte';
  import Modal from '$lib/components/shared/Modal.svelte';
  import { api } from '$lib/services/api';

  let showCreateModal = $state(false);
  let newName = $state('');
  let newSlug = $state('');
  let newDescription = $state('');
  let creating = $state(false);

  $effect(() => {
    newSlug = newName.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
  });

  async function createTeam() {
    creating = true;
    try {
      const team = await api.post<import('$lib/stores/teams').Team>('/api/teams', {
        name: newName,
        slug: newSlug,
        description: newDescription
      });
      teamsStore.update(teams => [...teams, team]);
      newName = '';
      newDescription = '';
      showCreateModal = false;
    } catch (e) {
      console.error('Failed to create team', e);
    } finally {
      creating = false;
    }
  }

  onMount(() => { loadTeams(); });
</script>

<div class="max-w-6xl mx-auto">
  <div class="flex items-center justify-between mb-6">
    <div>
      <h1 class="text-2xl font-bold text-[var(--dp-text)]">Teams</h1>
      <p class="text-[var(--dp-text-muted)] mt-1">Manage your teams and collaborators</p>
    </div>
    <button onclick={() => showCreateModal = true} class="px-4 py-2 rounded-lg bg-violet-600 hover:bg-violet-500 text-white text-sm font-medium transition-colors flex items-center gap-2">
      <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
      </svg>
      New Team
    </button>
  </div>

  {#if $teamsLoading}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {#each Array(6) as _}
        <SkeletonLoader type="card" />
      {/each}
    </div>
  {:else if $teamsStore.length === 0}
    <EmptyState title="No teams yet" description="Create a team to start collaborating with others." icon="teams" />
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 stagger-children">
      {#each $teamsStore as team}
        <a
          href="/teams/{team.id}"
          class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-6 hover:border-violet-500/30 hover-lift group"
        >
          <div class="flex items-center gap-3 mb-4">
            <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-violet-500 to-blue-500 flex items-center justify-center text-lg text-white font-bold">
              {team.name[0]}
            </div>
            <div>
              <h3 class="font-semibold text-[var(--dp-text)] group-hover:text-violet-400 transition-colors">{team.name}</h3>
              <p class="text-xs text-[var(--dp-text-muted)]">{team.slug}</p>
            </div>
          </div>
          <p class="text-sm text-[var(--dp-text-muted)] mb-4 line-clamp-2">{team.description || 'No description'}</p>
          <div class="flex items-center gap-4 text-xs text-[var(--dp-text-muted)]">
            <span class="flex items-center gap-1">
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z" />
              </svg>
              {team.memberCount} members
            </span>
          </div>
        </a>
      {/each}
    </div>
  {/if}
</div>

<Modal bind:open={showCreateModal} title="New Team">
  <form onsubmit={(e) => { e.preventDefault(); createTeam(); }} class="space-y-4">
    <div>
      <label for="team-name" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Name</label>
      <input id="team-name" type="text" bind:value={newName} placeholder="e.g. Frontend Team" required
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50" />
    </div>
    <div>
      <label for="team-slug" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Slug</label>
      <input id="team-slug" type="text" value={newSlug} readonly
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text-muted)] focus:outline-none" />
    </div>
    <div>
      <label for="team-desc" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Description</label>
      <textarea id="team-desc" bind:value={newDescription} placeholder="What does this team work on?" rows="3"
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50 resize-none"></textarea>
    </div>
    <div class="mt-5">
      <button type="submit" disabled={creating}
        class="w-full py-2.5 rounded-lg bg-violet-600 hover:bg-violet-500 disabled:opacity-50 disabled:cursor-not-allowed text-white text-sm font-medium transition-colors">
        {creating ? 'Creating...' : 'Create Team'}
      </button>
    </div>
  </form>
</Modal>
