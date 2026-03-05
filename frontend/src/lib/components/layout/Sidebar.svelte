<script lang="ts">
  import { page } from '$app/stores';

  let { collapsed = $bindable(false) } = $props();

  const navItems = [
    { href: '/', icon: 'dashboard', label: 'Dashboard' },
    { href: '/rooms', icon: 'code', label: 'Code Rooms' },
    { href: '/discussions', icon: 'chat', label: 'Discussions' },
    { href: '/docs', icon: 'docs', label: 'Documents' },
    { href: '/teams', icon: 'team', label: 'Teams' },
    { href: '/settings', icon: 'settings', label: 'Settings' }
  ];

  function isActive(href: string, pathname: string): boolean {
    if (href === '/') return pathname === '/';
    return pathname.startsWith(href);
  }

  const iconPaths: Record<string, string> = {
    dashboard: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0a1 1 0 01-1-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 01-1 1',
    code: 'M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4',
    chat: 'M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z',
    docs: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z',
    team: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z',
    settings: 'M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.066 2.573c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.573 1.066c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.066-2.573c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z M15 12a3 3 0 11-6 0 3 3 0 016 0z'
  };
</script>

<aside
  class="fixed left-0 top-0 h-screen z-40 flex flex-col border-r border-[var(--dp-border)] bg-[var(--dp-bg-card)] transition-all duration-300 ease-in-out"
  style="width: {collapsed ? '4.5rem' : '16rem'}"
>
  <!-- Logo -->
  <div class="flex items-center gap-3 px-4 h-16 border-b border-[var(--dp-border)]">
    <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-violet-500 to-blue-500 flex items-center justify-center shrink-0">
      <svg class="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path d="M13 10V3L4 14h7v7l9-11h-7z" />
      </svg>
    </div>
    {#if !collapsed}
      <span class="text-lg font-bold bg-gradient-to-r from-violet-400 to-blue-400 bg-clip-text text-transparent whitespace-nowrap">
        DevPulse
      </span>
    {/if}
  </div>

  <!-- Navigation -->
  <nav class="flex-1 py-4 px-3 space-y-1 overflow-y-auto">
    {#each navItems as item}
      {@const active = isActive(item.href, $page.url.pathname)}
      <a
        href={item.href}
        class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-200 group {active
          ? 'bg-violet-500/15 text-violet-400'
          : 'text-[var(--dp-text-muted)] hover:bg-white/5 hover:text-[var(--dp-text)]'}"
      >
        <svg class="w-5 h-5 shrink-0 {active ? 'text-violet-400' : 'text-[var(--dp-text-muted)] group-hover:text-[var(--dp-text)]'}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d={iconPaths[item.icon]} />
        </svg>
        {#if !collapsed}
          <span class="text-sm font-medium whitespace-nowrap">{item.label}</span>
        {/if}
        {#if active && !collapsed}
          <div class="ml-auto w-1.5 h-1.5 rounded-full bg-violet-400"></div>
        {/if}
      </a>
    {/each}
  </nav>

  <!-- Collapse toggle -->
  <div class="p-3 border-t border-[var(--dp-border)]">
    <button
      onclick={() => collapsed = !collapsed}
      aria-label={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
      class="flex items-center justify-center w-full py-2 rounded-lg text-[var(--dp-text-muted)] hover:bg-white/5 hover:text-[var(--dp-text)] transition-colors"
    >
      <svg class="w-5 h-5 transition-transform duration-300 {collapsed ? 'rotate-180' : ''}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
      </svg>
    </button>
  </div>
</aside>
