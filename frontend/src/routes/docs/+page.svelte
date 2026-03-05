<script lang="ts">
  import { onMount } from 'svelte';
  import { documentsStore, loadDocuments, documentsLoading, buildDocTree } from '$lib/stores/documents';
  import { teamsStore, loadTeams } from '$lib/stores/teams';
  import { timeAgo } from '$lib/utils/format';
  import EmptyState from '$lib/components/shared/EmptyState.svelte';
  import Modal from '$lib/components/shared/Modal.svelte';
  import { api } from '$lib/services/api';

  let selectedTeam = $state('');
  let docTree = $derived(buildDocTree($documentsStore));
  let showCreateModal = $state(false);
  let newTitle = $state('');
  let newSlug = $state('');
  let newContent = $state('');
  let creating = $state(false);

  $effect(() => {
    newSlug = newTitle.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
  });

  async function createDocument() {
    creating = true;
    try {
      const doc = await api.post<import('$lib/stores/documents').Document>(
        `/api/teams/${selectedTeam}/docs`,
        { title: newTitle, slug: newSlug, content: newContent }
      );
      documentsStore.update(docs => [...docs, doc]);
      newTitle = '';
      newContent = '';
      showCreateModal = false;
    } catch (e) {
      console.error('Failed to create document', e);
    } finally {
      creating = false;
    }
  }

  onMount(async () => {
    await loadTeams();
    if ($teamsStore.length > 0) {
      selectedTeam = $teamsStore[0].id;
      loadDocuments(selectedTeam);
    }
  });
</script>

<div class="max-w-6xl mx-auto">
  <div class="flex items-center justify-between mb-6">
    <div>
      <h1 class="text-2xl font-bold text-[var(--dp-text)]">Documents</h1>
      <p class="text-[var(--dp-text-muted)] mt-1">Team knowledge base and documentation</p>
    </div>
    <button onclick={() => showCreateModal = true} class="px-4 py-2 rounded-lg bg-violet-600 hover:bg-violet-500 text-white text-sm font-medium transition-colors flex items-center gap-2">
      <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
      </svg>
      New Document
    </button>
  </div>

  {#if $teamsStore.length > 0}
    <div class="flex gap-2 mb-6">
      {#each $teamsStore as team}
        <button
          onclick={() => { selectedTeam = team.id; loadDocuments(team.id); }}
          class="px-3 py-1.5 rounded-lg text-sm transition-colors {selectedTeam === team.id ? 'bg-violet-600 text-white' : 'bg-[var(--dp-bg-card)] text-[var(--dp-text-muted)] border border-[var(--dp-border)] hover:border-violet-500/30'}"
        >
          {team.name}
        </button>
      {/each}
    </div>
  {/if}

  {#if $documentsLoading}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {#each Array(6) as _}
        <div class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-5">
          <div class="flex items-start gap-3 mb-3">
            <div class="w-10 h-10 rounded-lg skeleton-shimmer"></div>
            <div class="flex-1">
              <div class="h-4 w-3/4 rounded skeleton-shimmer mb-2"></div>
              <div class="h-3 w-1/2 rounded skeleton-shimmer"></div>
            </div>
          </div>
          <div class="space-y-2 pl-3 border-l border-[var(--dp-border)] ml-2">
            <div class="h-3 w-full rounded skeleton-shimmer"></div>
            <div class="h-3 w-2/3 rounded skeleton-shimmer"></div>
          </div>
        </div>
      {/each}
    </div>
  {:else if $documentsStore.length === 0}
    <EmptyState title="No documents yet" description="Create documentation for your team's projects." icon="docs" />
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 stagger-children">
      {#each docTree as doc}
        <a
          href="/docs/{doc.id}"
          class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-5 hover:border-violet-500/30 hover-lift group"
        >
          <div class="flex items-start gap-3 mb-3">
            <div class="w-10 h-10 rounded-lg bg-blue-500/10 flex items-center justify-center shrink-0">
              <svg class="w-5 h-5 text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <div class="min-w-0">
              <h3 class="font-semibold text-[var(--dp-text)] group-hover:text-violet-400 transition-colors">{doc.title}</h3>
              <p class="text-xs text-[var(--dp-text-muted)] mt-0.5">{timeAgo(doc.updatedAt)}</p>
            </div>
          </div>
          {#if doc.children && doc.children.length > 0}
            <div class="pl-3 border-l border-[var(--dp-border)] ml-2 space-y-1.5">
              {#each doc.children.slice(0, 3) as child}
                <p class="text-sm text-[var(--dp-text-muted)]">{child.title}</p>
              {/each}
              {#if doc.children.length > 3}
                <p class="text-xs text-violet-400">+{doc.children.length - 3} more</p>
              {/if}
            </div>
          {/if}
        </a>
      {/each}
    </div>
  {/if}
</div>

<Modal bind:open={showCreateModal} title="New Document">
  <form onsubmit={(e) => { e.preventDefault(); createDocument(); }} class="space-y-4">
    <div>
      <label for="doc-title" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Title</label>
      <input id="doc-title" type="text" bind:value={newTitle} placeholder="e.g. Getting Started Guide" required
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50" />
    </div>
    <div>
      <label for="doc-slug" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Slug</label>
      <input id="doc-slug" type="text" value={newSlug} readonly
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text-muted)] focus:outline-none" />
    </div>
    <div>
      <label for="doc-content" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Content</label>
      <textarea id="doc-content" bind:value={newContent} placeholder="Start writing your document..." rows="6"
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50 resize-none"></textarea>
    </div>
    <div class="mt-5">
      <button type="submit" disabled={creating}
        class="w-full py-2.5 rounded-lg bg-violet-600 hover:bg-violet-500 disabled:opacity-50 disabled:cursor-not-allowed text-white text-sm font-medium transition-colors">
        {creating ? 'Creating...' : 'Create Document'}
      </button>
    </div>
  </form>
</Modal>
