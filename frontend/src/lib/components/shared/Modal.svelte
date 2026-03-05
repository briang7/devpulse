<script lang="ts">
  import { fly, fade } from 'svelte/transition';
  import type { Snippet } from 'svelte';

  let { open = $bindable(false), title = '', onclose = () => {}, children }: {
    open: boolean;
    title: string;
    onclose?: () => void;
    children: Snippet;
  } = $props();

  function close() {
    open = false;
    onclose();
  }

  function handleKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape') close();
  }
</script>

{#if open}
  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <div
    class="fixed inset-0 z-[60] flex items-center justify-center p-4"
    onkeydown={handleKeydown}
  >
    <div
      class="absolute inset-0 bg-black/60 backdrop-blur-sm"
      transition:fade={{ duration: 150 }}
      onclick={close}
      role="presentation"
    ></div>

    <div
      class="relative w-full max-w-lg rounded-2xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] shadow-2xl"
      transition:fly={{ y: 16, duration: 200 }}
    >
      <div class="flex items-center justify-between px-6 py-4 border-b border-[var(--dp-border)]">
        <h2 class="text-lg font-semibold text-[var(--dp-text)]">{title}</h2>
        <button
          onclick={close}
          aria-label="Close"
          class="p-1.5 rounded-lg text-[var(--dp-text-muted)] hover:bg-white/5 hover:text-[var(--dp-text)] transition-colors"
        >
          <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <div class="px-6 py-5">
        {@render children()}
      </div>
    </div>
  </div>
{/if}
