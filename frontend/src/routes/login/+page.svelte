<script lang="ts">
  import { getDemoUsers, loginWithDemo } from '$lib/stores/auth';
  import { goto } from '$app/navigation';

  const demoUsers = getDemoUsers();

  function handleLogin(uid: string) {
    loginWithDemo(uid);
    goto('/');
  }
</script>

<div class="min-h-screen bg-[var(--dp-bg-dark)] flex items-center justify-center px-4">
  <!-- Background gradient orbs -->
  <div class="fixed inset-0 overflow-hidden pointer-events-none">
    <div class="absolute -top-40 -right-40 w-80 h-80 bg-violet-500/10 rounded-full blur-3xl animate-fade-in"></div>
    <div class="absolute -bottom-40 -left-40 w-80 h-80 bg-blue-500/10 rounded-full blur-3xl animate-fade-in" style="animation-delay: 200ms"></div>
  </div>

  <div class="w-full max-w-md relative z-10">
    <!-- Logo -->
    <div class="text-center mb-8 animate-fade-in-up">
      <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-violet-500 to-blue-500 flex items-center justify-center mx-auto mb-4 shadow-lg shadow-violet-500/20">
        <svg class="w-9 h-9 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
      </div>
      <h1 class="text-3xl font-bold bg-gradient-to-r from-violet-400 to-blue-400 bg-clip-text text-transparent">
        DevPulse
      </h1>
      <p class="text-[var(--dp-text-muted)] mt-2">Real-time Developer Collaboration</p>
    </div>

    <!-- Demo login card -->
    <div class="rounded-2xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-6 animate-fade-in-up" style="animation-delay: 150ms">
      <h2 class="text-lg font-semibold text-[var(--dp-text)] mb-1">Sign in with demo account</h2>
      <p class="text-sm text-[var(--dp-text-muted)] mb-6">Choose a demo user to explore the platform</p>

      <div class="space-y-3 stagger-children">
        {#each demoUsers as user}
          <button
            onclick={() => handleLogin(user.uid)}
            class="w-full flex items-center gap-4 p-4 rounded-xl border border-[var(--dp-border)] hover:border-violet-500/50 hover:bg-violet-500/5 hover:-translate-y-0.5 transition-all duration-200 group text-left"
          >
            <div class="w-12 h-12 rounded-full bg-gradient-to-br from-violet-500 to-blue-500 flex items-center justify-center text-white font-semibold shrink-0">
              {user.displayName.split(' ').map(n => n[0]).join('')}
            </div>
            <div class="flex-1 min-w-0">
              <p class="font-medium text-[var(--dp-text)] group-hover:text-violet-400 transition-colors">{user.displayName}</p>
              <p class="text-sm text-[var(--dp-text-muted)] truncate">{user.bio}</p>
            </div>
            <svg class="w-5 h-5 text-[var(--dp-text-muted)] group-hover:text-violet-400 group-hover:translate-x-0.5 transition-all shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        {/each}
      </div>
    </div>

    <!-- Footer -->
    <p class="text-center text-xs text-[var(--dp-text-muted)] mt-6 animate-fade-in" style="animation-delay: 400ms">
      DevPulse — A WebVista Portfolio Project
    </p>
  </div>
</div>
