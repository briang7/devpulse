<script lang="ts">
  import { onMount } from 'svelte';
  import { currentUser } from '$lib/stores/auth';
  import { teamsStore, loadTeams } from '$lib/stores/teams';
  import { roomsStore, loadRooms } from '$lib/stores/rooms';
  import { activitiesStore, loadActivities } from '$lib/stores/activities';
  import { timeAgo } from '$lib/utils/format';

  let activeFilter = $state('all');
  const filters = [
    { key: 'all', label: 'All' },
    { key: 'room', label: 'Rooms' },
    { key: 'discussion', label: 'Discussions' },
    { key: 'document', label: 'Docs' },
    { key: 'team', label: 'Teams' }
  ];

  const filteredActivities = $derived(
    activeFilter === 'all'
      ? $activitiesStore
      : $activitiesStore.filter(a => a.targetType === activeFilter)
  );

  onMount(() => {
    loadTeams();
    loadRooms();
    loadActivities();
  });

  const greeting = $derived(() => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  });

  function activityHref(activity: import('$lib/stores/activities').Activity): string {
    const id = activity.targetId;
    switch (activity.targetType) {
      case 'room': return `/rooms/${id}`;
      case 'discussion': return `/discussions/${id}`;
      case 'document': return `/docs/${id}`;
      case 'project': return `/teams/${activity.teamId}`;
      case 'team': return `/teams/${id}`;
      default: return '#';
    }
  }

  const actionIcons: Record<string, string> = {
    created: 'M12 4v16m8-8H4',
    updated: 'M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L10.582 16.07a4.5 4.5 0 01-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 011.13-1.897l8.932-8.931z',
    posted: 'M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z',
    joined: 'M18 7.5v3m0 0v3m0-3h3m-3 0h-3m-2.25-4.125a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zM3 19.235v-.11a6.375 6.375 0 0112.75 0v.109A12.318 12.318 0 019.374 21c-2.331 0-4.512-.645-6.374-1.766z',
    deleted: 'M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0'
  };
</script>

<div class="max-w-7xl mx-auto space-y-8">
  <!-- Welcome -->
  <div>
    <h1 class="text-2xl font-bold text-[var(--dp-text)]">
      {greeting()}, {$currentUser?.displayName?.split(' ')[0] || 'Developer'}
    </h1>
    <p class="text-[var(--dp-text-muted)] mt-1">Here's what's happening across your teams.</p>
  </div>

  <!-- Stats cards -->
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4 stagger-children">
    {#each [
      { label: 'Teams', value: $teamsStore.length, icon: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z', color: 'violet' },
      { label: 'Active Rooms', value: $roomsStore.length, icon: 'M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4', color: 'blue' },
      { label: 'Activities', value: $activitiesStore.length, icon: 'M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 013 19.875v-6.75zM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V8.625zM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V4.125z', color: 'emerald' },
      { label: 'Online Now', value: 3, icon: 'M9.348 14.652a3.75 3.75 0 010-5.304m5.304 0a3.75 3.75 0 010 5.304m-7.425 2.121a6.75 6.75 0 010-9.546m9.546 0a6.75 6.75 0 010 9.546M5.106 18.894c-3.808-3.807-3.808-9.98 0-13.788m13.788 0c3.808 3.807 3.808 9.98 0 13.788M12 12h.008v.008H12V12zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z', color: 'amber' }
    ] as stat}
      <div class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-5 hover:border-{stat.color}-500/30 hover:-translate-y-0.5 transition-all duration-200">
        <div class="flex items-center justify-between mb-3">
          <span class="text-sm text-[var(--dp-text-muted)]">{stat.label}</span>
          <div class="w-9 h-9 rounded-lg bg-{stat.color}-500/10 flex items-center justify-center">
            <svg class="w-5 h-5 text-{stat.color}-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round" d={stat.icon} />
            </svg>
          </div>
        </div>
        <p class="text-3xl font-bold text-[var(--dp-text)]">{stat.value}</p>
      </div>
    {/each}
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <!-- Recent rooms -->
    <div class="lg:col-span-1 rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-5">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-[var(--dp-text)]">Active Rooms</h2>
        <a href="/rooms" class="text-sm text-violet-400 hover:text-violet-300">View all</a>
      </div>
      {#if $roomsStore.length === 0}
        <p class="text-sm text-[var(--dp-text-muted)] py-8 text-center">No active rooms</p>
      {:else}
        <div class="space-y-3">
          {#each $roomsStore.slice(0, 5) as room}
            <a href="/rooms/{room.id}" class="flex items-center gap-3 p-3 rounded-lg hover:bg-white/5 transition-colors">
              <div class="w-10 h-10 rounded-lg bg-blue-500/10 flex items-center justify-center shrink-0">
                <svg class="w-5 h-5 text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
                </svg>
              </div>
              <div class="min-w-0 flex-1">
                <p class="text-sm font-medium text-[var(--dp-text)] truncate">{room.name}</p>
                <p class="text-xs text-[var(--dp-text-muted)]">{room.language} &middot; {room.team?.name || 'Team'}</p>
              </div>
              <span class="text-xs text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded-full shrink-0 flex items-center gap-1.5">
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 pulse-glow"></span>
                Live
              </span>
            </a>
          {/each}
        </div>
      {/if}
    </div>

    <!-- Activity feed -->
    <div class="lg:col-span-2 rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-5">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-[var(--dp-text)]">Recent Activity</h2>
      </div>

      <!-- Filter chips -->
      <div class="flex items-center gap-2 mb-4 overflow-x-auto pb-1">
        {#each filters as filter}
          <button
            onclick={() => activeFilter = filter.key}
            class="px-3 py-1 rounded-full text-xs font-medium whitespace-nowrap transition-all duration-200
              {activeFilter === filter.key
                ? 'bg-violet-600 text-white'
                : 'bg-[var(--dp-bg-surface)] text-[var(--dp-text-muted)] hover:text-[var(--dp-text)] hover:bg-white/5 border border-[var(--dp-border)]'}"
          >
            {filter.label}
          </button>
        {/each}
      </div>

      {#if filteredActivities.length === 0}
        <p class="text-sm text-[var(--dp-text-muted)] py-8 text-center">No activity matching this filter</p>
      {:else}
        <div class="space-y-1 stagger-children">
          {#each filteredActivities.slice(0, 10) as activity}
            <a href={activityHref(activity)} class="flex items-start gap-3 p-3 rounded-lg hover:bg-white/5 transition-colors group">
              <div class="w-8 h-8 rounded-full bg-gradient-to-br from-violet-500 to-blue-500 flex items-center justify-center text-xs text-white font-semibold shrink-0 mt-0.5">
                {activity.actor?.displayName?.split(' ').map(n => n[0]).join('') || '?'}
              </div>
              <div class="min-w-0 flex-1">
                <p class="text-sm text-[var(--dp-text)]">
                  <span class="font-medium">{activity.actor?.displayName || 'Someone'}</span>
                  {' '}{activity.action}{' '}
                  <span class="text-violet-400 group-hover:text-violet-300">{activity.targetName}</span>
                </p>
                <p class="text-xs text-[var(--dp-text-muted)] mt-0.5">{timeAgo(activity.createdAt)}</p>
              </div>
              <svg class="w-4 h-4 text-[var(--dp-text-muted)] group-hover:text-violet-400 shrink-0 mt-1 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d={actionIcons[activity.action] || actionIcons.created} />
              </svg>
            </a>
          {/each}
        </div>
      {/if}
    </div>
  </div>
</div>
