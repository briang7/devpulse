<script lang="ts">
  import { onMount } from 'svelte';
  import { discussionsStore, loadDiscussions, discussionsLoading } from '$lib/stores/discussions';
  import { teamsStore, loadTeams } from '$lib/stores/teams';
  import { timeAgo } from '$lib/utils/format';
  import EmptyState from '$lib/components/shared/EmptyState.svelte';
  import SkeletonLoader from '$lib/components/shared/SkeletonLoader.svelte';
  import Badge from '$lib/components/shared/Badge.svelte';
  import Modal from '$lib/components/shared/Modal.svelte';
  import { api } from '$lib/services/api';

  let selectedTeam = $state('');
  let showCreateModal = $state(false);
  let newTitle = $state('');
  let newContent = $state('');
  let newTags = $state('');
  let creating = $state(false);

  async function createDiscussion() {
    creating = true;
    try {
      const discussion = await api.post<import('$lib/stores/discussions').Discussion>(
        `/api/teams/${selectedTeam}/discussions`,
        {
          title: newTitle,
          content: newContent,
          tags: newTags.split(',').map(t => t.trim()).filter(Boolean)
        }
      );
      discussionsStore.update(d => [discussion, ...d]);
      newTitle = '';
      newContent = '';
      newTags = '';
      showCreateModal = false;
    } catch (e) {
      console.error('Failed to create discussion', e);
    } finally {
      creating = false;
    }
  }

  onMount(async () => {
    await loadTeams();
    if ($teamsStore.length > 0) {
      selectedTeam = $teamsStore[0].id;
      loadDiscussions(selectedTeam);
    }
  });

  function onTeamChange() {
    if (selectedTeam) loadDiscussions(selectedTeam);
  }
</script>

<div class="max-w-4xl mx-auto">
  <div class="flex items-center justify-between mb-6">
    <div>
      <h1 class="text-2xl font-bold text-[var(--dp-text)]">Discussions</h1>
      <p class="text-[var(--dp-text-muted)] mt-1">Threaded conversations with your team</p>
    </div>
    <button onclick={() => showCreateModal = true} class="px-4 py-2 rounded-lg bg-violet-600 hover:bg-violet-500 text-white text-sm font-medium transition-colors flex items-center gap-2">
      <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
      </svg>
      New Discussion
    </button>
  </div>

  {#if $teamsStore.length > 0}
    <div class="flex gap-2 mb-6">
      {#each $teamsStore as team}
        <button
          onclick={() => { selectedTeam = team.id; onTeamChange(); }}
          class="px-3 py-1.5 rounded-lg text-sm transition-colors {selectedTeam === team.id ? 'bg-violet-600 text-white' : 'bg-[var(--dp-bg-card)] text-[var(--dp-text-muted)] border border-[var(--dp-border)] hover:border-violet-500/30'}"
        >
          {team.name}
        </button>
      {/each}
    </div>
  {/if}

  {#if $discussionsLoading && $discussionsStore.length === 0}
    <div class="space-y-4">
      {#each Array(5) as _}
        <SkeletonLoader type="card" />
      {/each}
    </div>
  {:else if !$discussionsLoading && $discussionsStore.length === 0}
    <EmptyState title="No discussions yet" description="Start a discussion to collaborate with your team." icon="discussions" />
  {:else}
    <div class="space-y-3 stagger-children">
      {#each $discussionsStore as discussion}
        <a
          href="/discussions/{discussion.id}"
          class="block rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-5 hover:border-violet-500/30 hover:-translate-y-0.5 transition-all duration-200"
        >
          <div class="flex items-start gap-4">
            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-violet-500 to-blue-500 flex items-center justify-center text-sm text-white font-semibold shrink-0">
              {discussion.author?.displayName?.split(' ').map(n => n[0]).join('') || '?'}
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 mb-1">
                {#if discussion.isPinned}
                  <svg class="w-4 h-4 text-amber-400 shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z" />
                  </svg>
                {/if}
                <h3 class="font-semibold text-[var(--dp-text)] truncate">{discussion.title}</h3>
              </div>
              <p class="text-sm text-[var(--dp-text-muted)] line-clamp-2 mb-3">{discussion.content.slice(0, 200)}</p>
              <div class="flex items-center flex-wrap gap-2">
                {#each (discussion.tags || []) as tag}
                  <Badge text={tag} variant="primary" />
                {/each}
                <span class="text-xs text-[var(--dp-text-muted)]">
                  {discussion.author?.displayName} &middot; {timeAgo(discussion.createdAt)} &middot; {discussion.replyCount} replies
                </span>
              </div>
            </div>
          </div>
        </a>
      {/each}
    </div>
  {/if}
</div>

<Modal bind:open={showCreateModal} title="New Discussion">
  <form onsubmit={(e) => { e.preventDefault(); createDiscussion(); }} class="space-y-4">
    <div>
      <label for="disc-title" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Title</label>
      <input id="disc-title" type="text" bind:value={newTitle} placeholder="e.g. How should we handle auth?" required
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50" />
    </div>
    <div>
      <label for="disc-content" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Content</label>
      <textarea id="disc-content" bind:value={newContent} placeholder="Describe the topic you want to discuss..." rows="6" required
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50 resize-none"></textarea>
    </div>
    <div>
      <label for="disc-tags" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Tags</label>
      <input id="disc-tags" type="text" bind:value={newTags} placeholder="e.g. frontend, auth, urgent (comma-separated)"
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50" />
    </div>
    <div class="mt-5">
      <button type="submit" disabled={creating}
        class="w-full py-2.5 rounded-lg bg-violet-600 hover:bg-violet-500 disabled:opacity-50 disabled:cursor-not-allowed text-white text-sm font-medium transition-colors">
        {creating ? 'Creating...' : 'Create Discussion'}
      </button>
    </div>
  </form>
</Modal>
