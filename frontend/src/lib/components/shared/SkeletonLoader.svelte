<script lang="ts">
  let { lines = 3, type = 'text' as 'text' | 'card' | 'list' } = $props();
</script>

{#if type === 'card'}
  <div class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-6 animate-pulse">
    <div class="h-4 bg-[var(--dp-bg-surface)] rounded w-3/4 mb-4"></div>
    <div class="h-3 bg-[var(--dp-bg-surface)] rounded w-full mb-2"></div>
    <div class="h-3 bg-[var(--dp-bg-surface)] rounded w-5/6 mb-4"></div>
    <div class="flex gap-2">
      <div class="h-6 bg-[var(--dp-bg-surface)] rounded-full w-16"></div>
      <div class="h-6 bg-[var(--dp-bg-surface)] rounded-full w-20"></div>
    </div>
  </div>
{:else if type === 'list'}
  {#each Array(lines) as _, i}
    <div class="flex items-center gap-4 p-4 animate-pulse" style="animation-delay: {i * 100}ms">
      <div class="w-10 h-10 bg-[var(--dp-bg-surface)] rounded-full shrink-0"></div>
      <div class="flex-1">
        <div class="h-4 bg-[var(--dp-bg-surface)] rounded w-1/3 mb-2"></div>
        <div class="h-3 bg-[var(--dp-bg-surface)] rounded w-2/3"></div>
      </div>
    </div>
  {/each}
{:else}
  <div class="space-y-3 animate-pulse">
    {#each Array(lines) as _, i}
      <div
        class="h-3 bg-[var(--dp-bg-surface)] rounded"
        style="width: {100 - i * 15}%; animation-delay: {i * 100}ms"
      ></div>
    {/each}
  </div>
{/if}
