<script lang="ts">
  import { fly, fade } from 'svelte/transition';
  import { page } from '$app/stores';

  let { children } = $props();

  // Use page pathname as transition key
  let key = $derived($page.url.pathname);
</script>

{#key key}
  <div
    in:fly={{ y: 12, duration: 300, delay: 100 }}
    out:fade={{ duration: 150 }}
  >
    {@render children()}
  </div>
{/key}
