<script lang="ts">
  import { onMount } from 'svelte';
  import { currentUser, updateProfile } from '$lib/stores/auth';
  import { get } from 'svelte/store';
  import Avatar from '$lib/components/shared/Avatar.svelte';

  let displayName = $state('');
  let bio = $state('');
  let saved = $state(false);

  // Initialize form values once on mount
  onMount(() => {
    const user = get(currentUser);
    if (user) {
      displayName = user.displayName;
      bio = user.bio;
    }
  });

  function saveChanges() {
    updateProfile({ displayName, bio });
    saved = true;
    setTimeout(() => saved = false, 2000);
  }
</script>

<div class="max-w-2xl mx-auto">
  <h1 class="text-2xl font-bold text-[var(--dp-text)] mb-6 animate-fade-in-up">Settings</h1>

  {#if $currentUser}
    <div class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-6 mb-6 animate-fade-in-up" style="animation-delay: 100ms">
      <h2 class="text-lg font-semibold text-[var(--dp-text)] mb-4">Profile</h2>
      <div class="flex items-center gap-4 mb-6">
        <Avatar name={displayName} size="xl" />
        <div>
          <p class="text-lg font-medium text-[var(--dp-text)]">{displayName}</p>
          <p class="text-sm text-[var(--dp-text-muted)]">{$currentUser.email}</p>
        </div>
      </div>

      <div class="space-y-4">
        <div>
          <label for="display-name" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1">Display Name</label>
          <input
            id="display-name"
            type="text"
            bind:value={displayName}
            class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] focus:outline-none focus:ring-2 focus:ring-violet-500/50"
          />
        </div>
        <div>
          <label for="user-bio" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1">Bio</label>
          <textarea
            id="user-bio"
            bind:value={bio}
            rows="3"
            class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] focus:outline-none focus:ring-2 focus:ring-violet-500/50 resize-none"
          ></textarea>
        </div>
      </div>

      <div class="mt-6 flex items-center gap-3">
        <button
          onclick={saveChanges}
          class="px-4 py-2 rounded-lg bg-violet-600 hover:bg-violet-500 text-white text-sm font-medium transition-colors"
        >
          Save Changes
        </button>
        {#if saved}
          <span class="text-sm text-emerald-400 animate-fade-in">Saved!</span>
        {/if}
      </div>
    </div>

    <div class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-6 animate-fade-in-up" style="animation-delay: 200ms">
      <h2 class="text-lg font-semibold text-[var(--dp-text)] mb-4">Appearance</h2>
      <p class="text-sm text-[var(--dp-text-muted)]">DevPulse uses a dark theme optimized for developers.</p>
    </div>
  {/if}
</div>
