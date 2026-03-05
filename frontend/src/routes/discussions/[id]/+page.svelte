<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { currentDiscussion, discussionReplies, loadDiscussion, toggleReaction, togglePin } from '$lib/stores/discussions';
  import { currentUser } from '$lib/stores/auth';
  import { timeAgo } from '$lib/utils/format';
  import { renderMarkdown } from '$lib/utils/markdown';
  import { api } from '$lib/services/api';
  import Badge from '$lib/components/shared/Badge.svelte';
  import type { Reaction, Reply } from '$lib/stores/discussions';

  let replyContent = $state('');
  let posting = $state(false);

  const reactionEmojis = ['👍', '❤️', '🎉', '🚀', '👀', '💡'];

  function hasUserReacted(reactions: Reaction[] | undefined, emoji: string): boolean {
    if (!reactions || !$currentUser) return false;
    return reactions.some(r => r.emoji === emoji && r.userId === $currentUser!.id);
  }

  function emojiCount(reactions: Reaction[] | undefined, emoji: string): number {
    if (!reactions) return 0;
    return reactions.filter(r => r.emoji === emoji).length;
  }

  async function handleReaction(emoji: string, targetType: 'discussion' | 'reply', targetId: string) {
    await toggleReaction($page.params.id, emoji, targetType, targetId);
  }

  async function handleTogglePin() {
    await togglePin($page.params.id);
  }

  async function postReply() {
    if (!replyContent.trim() || !$currentUser) return;
    posting = true;
    try {
      const reply = await api.post<Reply>(
        `/api/discussions/${$page.params.id}/replies`,
        { content: replyContent }
      );
      discussionReplies.update(replies => [...replies, reply]);
      replyContent = '';
    } catch (e) {
      console.error('Failed to post reply', e);
    } finally {
      posting = false;
    }
  }

  onMount(() => {
    loadDiscussion($page.params.id);
  });
</script>

<div class="max-w-4xl mx-auto">
  {#if $currentDiscussion}
    <!-- Header -->
    <div class="mb-6 animate-fade-in-up">
      <div class="flex items-center justify-between">
        <a href="/discussions" class="text-sm text-violet-400 hover:text-violet-300 mb-3 inline-flex items-center gap-1 group">
          <svg class="w-4 h-4 group-hover:-translate-x-0.5 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
          </svg>
          Back to discussions
        </a>
        <button
          onclick={handleTogglePin}
          class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-all duration-200
            {$currentDiscussion.isPinned
              ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30'
              : 'bg-[var(--dp-bg-surface)] text-[var(--dp-text-muted)] hover:text-amber-400 hover:bg-amber-500/10 border border-[var(--dp-border)]'}"
        >
          <svg class="w-3.5 h-3.5" fill="{$currentDiscussion.isPinned ? 'currentColor' : 'none'}" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 3.75V16.5L12 14.25 7.5 16.5V3.75m9 0H18A2.25 2.25 0 0120.25 6v12A2.25 2.25 0 0118 20.25H6A2.25 2.25 0 013.75 18V6A2.25 2.25 0 016 3.75h1.5m9 0h-9" />
          </svg>
          {$currentDiscussion.isPinned ? 'Pinned' : 'Pin'}
        </button>
      </div>
      <h1 class="text-2xl font-bold text-[var(--dp-text)] mt-2 flex items-center gap-2">
        {#if $currentDiscussion.isPinned}
          <svg class="w-5 h-5 text-amber-400 shrink-0" fill="currentColor" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1">
            <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 3.75V16.5L12 14.25 7.5 16.5V3.75m9 0H18A2.25 2.25 0 0120.25 6v12A2.25 2.25 0 0118 20.25H6A2.25 2.25 0 013.75 18V6A2.25 2.25 0 016 3.75h1.5m9 0h-9" />
          </svg>
        {/if}
        {$currentDiscussion.title}
      </h1>
      <div class="flex items-center gap-3 mt-2">
        <div class="flex items-center gap-2">
          <div class="w-6 h-6 rounded-full bg-gradient-to-br from-violet-500 to-blue-500 flex items-center justify-center text-[10px] text-white font-bold">
            {$currentDiscussion.author?.displayName?.[0] || '?'}
          </div>
          <span class="text-sm text-[var(--dp-text)]">{$currentDiscussion.author?.displayName}</span>
        </div>
        <span class="text-sm text-[var(--dp-text-muted)]">{timeAgo($currentDiscussion.createdAt)}</span>
        {#each ($currentDiscussion.tags || []) as tag}
          <Badge text={tag} variant="primary" />
        {/each}
      </div>
    </div>

    <!-- Content -->
    <div class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-6 mb-2 animate-fade-in-up" style="animation-delay: 100ms">
      <div class="prose prose-invert max-w-none text-[var(--dp-text)]">
        {@html renderMarkdown($currentDiscussion.content)}
      </div>
    </div>

    <!-- Discussion reactions -->
    <div class="flex items-center gap-1.5 mb-6 px-1 animate-fade-in-up" style="animation-delay: 150ms">
      {#each reactionEmojis as emoji}
        {@const count = emojiCount($currentDiscussion.reactions, emoji)}
        {@const reacted = hasUserReacted($currentDiscussion.reactions, emoji)}
        <button
          onclick={() => handleReaction(emoji, 'discussion', $currentDiscussion!.id)}
          class="flex items-center gap-1 px-2.5 py-1 rounded-full text-sm transition-all duration-200
            {reacted
              ? 'bg-violet-500/20 border border-violet-500/40 scale-105'
              : 'bg-[var(--dp-bg-surface)] border border-[var(--dp-border)] hover:border-violet-500/30 hover:bg-violet-500/10'}
            {count > 0 ? '' : 'opacity-60 hover:opacity-100'}"
        >
          <span>{emoji}</span>
          {#if count > 0}
            <span class="text-xs font-medium {reacted ? 'text-violet-400' : 'text-[var(--dp-text-muted)]'}">{count}</span>
          {/if}
        </button>
      {/each}
    </div>

    <!-- Replies -->
    <div class="space-y-4">
      <h2 class="text-lg font-semibold text-[var(--dp-text)] animate-fade-in" style="animation-delay: 200ms">{$discussionReplies.length} Replies</h2>
      {#each $discussionReplies as reply, i}
        <div class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-5 animate-fade-in-up" style="animation-delay: {250 + i * 60}ms">
          <div class="flex items-center gap-2 mb-3">
            <div class="w-8 h-8 rounded-full bg-gradient-to-br from-violet-500 to-blue-500 flex items-center justify-center text-xs text-white font-bold">
              {reply.author?.displayName?.[0] || '?'}
            </div>
            <div>
              <span class="text-sm font-medium text-[var(--dp-text)]">{reply.author?.displayName}</span>
              <span class="text-xs text-[var(--dp-text-muted)] ml-2">{timeAgo(reply.createdAt)}</span>
            </div>
          </div>
          <div class="prose prose-invert prose-sm max-w-none text-[var(--dp-text)] pl-10">
            {@html renderMarkdown(reply.content)}
          </div>
          <!-- Reply reactions -->
          <div class="flex items-center gap-1 mt-3 pl-10">
            {#each reactionEmojis as emoji}
              {@const count = emojiCount(reply.reactions, emoji)}
              {@const reacted = hasUserReacted(reply.reactions, emoji)}
              <button
                onclick={() => handleReaction(emoji, 'reply', reply.id)}
                class="flex items-center gap-1 px-2 py-0.5 rounded-full text-xs transition-all duration-200
                  {reacted
                    ? 'bg-violet-500/20 border border-violet-500/40'
                    : 'bg-[var(--dp-bg-surface)] border border-transparent hover:border-[var(--dp-border)] hover:bg-violet-500/10'}
                  {count > 0 ? '' : 'opacity-40 hover:opacity-100'}"
              >
                <span>{emoji}</span>
                {#if count > 0}
                  <span class="font-medium {reacted ? 'text-violet-400' : 'text-[var(--dp-text-muted)]'}">{count}</span>
                {/if}
              </button>
            {/each}
          </div>
        </div>
      {/each}
    </div>

    <!-- Reply input -->
    <div class="mt-6 rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-5">
      <form onsubmit={(e) => { e.preventDefault(); postReply(); }}>
        <textarea
          bind:value={replyContent}
          placeholder="Write a reply... (Markdown supported)"
          rows="3"
          class="w-full px-4 py-3 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50 resize-none"
        ></textarea>
        <div class="flex justify-end mt-3">
          <button
            type="submit"
            disabled={posting || !replyContent.trim()}
            class="px-4 py-2 rounded-lg bg-violet-600 hover:bg-violet-500 disabled:opacity-50 disabled:cursor-not-allowed text-white text-sm font-medium transition-colors"
          >
            {posting ? 'Posting...' : 'Post Reply'}
          </button>
        </div>
      </form>
    </div>
  {:else}
    <div class="flex items-center justify-center py-16">
      <p class="text-[var(--dp-text-muted)]">Loading discussion...</p>
    </div>
  {/if}
</div>
