<script lang="ts">
  import { onMount } from 'svelte';
  import { slide, fly } from 'svelte/transition';
  import { page } from '$app/stores';
  import { currentDocument, loadDocument, loadVersions, documentVersions, updateDocument, createVersion } from '$lib/stores/documents';
  import { currentUser } from '$lib/stores/auth';
  import { renderMarkdown } from '$lib/utils/markdown';
  import { timeAgo, formatDateTime } from '$lib/utils/format';

  let editing = $state(false);
  let editTitle = $state('');
  let editContent = $state('');
  let saving = $state(false);
  let showVersions = $state(false);
  let previewVersion = $state<import('$lib/stores/documents').DocumentVersion | null>(null);

  async function startEdit() {
    if (!$currentDocument) return;
    editTitle = $currentDocument.title;
    editContent = $currentDocument.content;
    editing = true;
  }

  function cancelEdit() {
    editing = false;
    previewVersion = null;
  }

  async function saveDocument() {
    if (!$currentDocument || saving) return;
    saving = true;
    try {
      await updateDocument($currentDocument.id, { title: editTitle, content: editContent });
      await createVersion($currentDocument.id, { title: editTitle, content: editContent });
      editing = false;
      // Reload versions
      await loadVersions($currentDocument.id);
    } catch (e) {
      console.error('Failed to save document', e);
    } finally {
      saving = false;
    }
  }

  function previewVersionContent(version: import('$lib/stores/documents').DocumentVersion) {
    previewVersion = version;
  }

  function restoreVersion(version: import('$lib/stores/documents').DocumentVersion) {
    editTitle = version.title;
    editContent = version.content;
    previewVersion = null;
    editing = true;
  }

  onMount(async () => {
    await loadDocument($page.params.id);
    loadVersions($page.params.id);
  });
</script>

<div class="max-w-6xl mx-auto flex gap-6">
  <!-- Main content -->
  <div class="flex-1 min-w-0">
    {#if $currentDocument}
      <div class="mb-6 animate-fade-in-up">
        <div class="flex items-center justify-between">
          <a href="/docs" class="text-sm text-violet-400 hover:text-violet-300 mb-3 inline-flex items-center gap-1 group">
            <svg class="w-4 h-4 group-hover:-translate-x-0.5 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
            </svg>
            Back to documents
          </a>
          <div class="flex items-center gap-2">
            <button
              onclick={() => showVersions = !showVersions}
              class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium bg-[var(--dp-bg-surface)] text-[var(--dp-text-muted)] hover:text-[var(--dp-text)] border border-[var(--dp-border)] hover:border-violet-500/30 transition-all"
            >
              <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              History
              {#if $documentVersions.length > 0}
                <span class="px-1.5 py-0.5 rounded-full bg-violet-500/20 text-violet-400 text-[10px]">{$documentVersions.length}</span>
              {/if}
            </button>
            {#if !editing}
              <button
                onclick={startEdit}
                class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium bg-violet-600 hover:bg-violet-500 text-white transition-colors"
              >
                <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L10.582 16.07a4.5 4.5 0 01-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 011.13-1.897l8.932-8.931z" />
                </svg>
                Edit
              </button>
            {:else}
              <button
                onclick={cancelEdit}
                class="px-3 py-1.5 rounded-lg text-xs font-medium bg-[var(--dp-bg-surface)] text-[var(--dp-text-muted)] hover:text-[var(--dp-text)] border border-[var(--dp-border)] transition-all"
              >
                Cancel
              </button>
              <button
                onclick={saveDocument}
                disabled={saving}
                class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium bg-emerald-600 hover:bg-emerald-500 disabled:opacity-50 text-white transition-colors"
              >
                {#if saving}
                  <div class="w-3 h-3 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                  Saving...
                {:else}
                  <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                  </svg>
                  Save
                {/if}
              </button>
            {/if}
          </div>
        </div>

        {#if editing}
          <input
            bind:value={editTitle}
            class="text-2xl font-bold text-[var(--dp-text)] mt-2 w-full bg-transparent border-b border-[var(--dp-border)] focus:border-violet-500 focus:outline-none pb-2 transition-colors"
            placeholder="Document title"
          />
        {:else}
          <h1 class="text-2xl font-bold text-[var(--dp-text)] mt-2">{previewVersion?.title || $currentDocument.title}</h1>
        {/if}
        <div class="flex items-center gap-3 mt-2 text-sm text-[var(--dp-text-muted)]">
          <span>by {$currentDocument.author?.displayName || 'Unknown'}</span>
          {#if previewVersion}
            <span class="text-amber-400">Viewing version {previewVersion.version}</span>
          {/if}
        </div>
      </div>

      <div class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-8 animate-fade-in-up" style="animation-delay: 100ms">
        {#if editing}
          <textarea
            bind:value={editContent}
            rows="20"
            class="w-full bg-transparent text-sm text-[var(--dp-text)] font-mono placeholder:text-[var(--dp-text-muted)] focus:outline-none resize-none leading-relaxed"
            placeholder="Write your document content in Markdown..."
          ></textarea>
        {:else if previewVersion}
          <div class="prose prose-invert max-w-none text-[var(--dp-text)]">
            {@html renderMarkdown(previewVersion.content) || 'No content.'}
          </div>
        {:else}
          <div class="prose prose-invert max-w-none text-[var(--dp-text)]">
            {@html renderMarkdown($currentDocument.content) || 'No content yet.'}
          </div>
        {/if}
      </div>
    {:else}
      <div class="flex flex-col items-center justify-center py-16 gap-3 animate-fade-in">
        <div class="w-8 h-8 rounded-lg skeleton-shimmer"></div>
        <p class="text-[var(--dp-text-muted)]">Loading document...</p>
      </div>
    {/if}
  </div>

  <!-- Version history sidebar -->
  {#if showVersions}
    <div class="w-72 shrink-0 animate-slide-in-right" transition:fly={{ x: 20, duration: 200 }}>
      <div class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-4 sticky top-20">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-sm font-semibold text-[var(--dp-text)]">Version History</h3>
          <button onclick={() => { showVersions = false; previewVersion = null; }} class="text-[var(--dp-text-muted)] hover:text-[var(--dp-text)]">
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        {#if $documentVersions.length === 0}
          <p class="text-xs text-[var(--dp-text-muted)] text-center py-6">No versions yet. Save the document to create one.</p>
        {:else}
          <div class="space-y-2 max-h-[60vh] overflow-y-auto">
            {#each $documentVersions as version}
              <div
                class="p-3 rounded-lg border transition-all cursor-pointer
                  {previewVersion?.id === version.id
                    ? 'border-violet-500/50 bg-violet-500/10'
                    : 'border-[var(--dp-border)] hover:border-violet-500/30 hover:bg-white/[0.02]'}"
              >
                <button
                  type="button"
                  class="w-full text-left"
                  onclick={() => previewVersionContent(version)}
                >
                  <div class="flex items-center justify-between mb-1">
                    <span class="text-xs font-semibold text-violet-400">v{version.version}</span>
                    <span class="text-[10px] text-[var(--dp-text-muted)]">{timeAgo(version.createdAt)}</span>
                  </div>
                  <p class="text-xs text-[var(--dp-text)] truncate">{version.title}</p>
                  <p class="text-[10px] text-[var(--dp-text-muted)] mt-1">{version.author?.displayName || 'Unknown'}</p>
                </button>
                {#if previewVersion?.id === version.id}
                  <button
                    onclick={() => restoreVersion(version)}
                    class="mt-2 w-full text-center px-2 py-1 rounded text-[10px] font-medium bg-violet-600 hover:bg-violet-500 text-white transition-colors"
                  >
                    Restore this version
                  </button>
                {/if}
              </div>
            {/each}
          </div>
        {/if}
      </div>
    </div>
  {/if}
</div>
