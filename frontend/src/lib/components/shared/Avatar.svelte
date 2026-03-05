<script lang="ts">
  let { name = '', url = '', size = 'md' as 'sm' | 'md' | 'lg' | 'xl', status = '' as '' | 'online' | 'away' | 'offline' } = $props();

  const sizeClasses: Record<string, string> = {
    sm: 'w-8 h-8 text-xs',
    md: 'w-10 h-10 text-sm',
    lg: 'w-12 h-12 text-base',
    xl: 'w-16 h-16 text-lg'
  };

  const statusColors: Record<string, string> = {
    online: 'bg-emerald-400',
    away: 'bg-amber-400',
    offline: 'bg-gray-500'
  };

  function getInitials(name: string): string {
    return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
  }

  function getColor(name: string): string {
    const colors = [
      'from-violet-500 to-purple-600',
      'from-blue-500 to-cyan-500',
      'from-emerald-500 to-teal-500',
      'from-orange-500 to-amber-500',
      'from-pink-500 to-rose-500',
      'from-indigo-500 to-blue-500'
    ];
    let hash = 0;
    for (let i = 0; i < name.length; i++) {
      hash = name.charCodeAt(i) + ((hash << 5) - hash);
    }
    return colors[Math.abs(hash) % colors.length];
  }
</script>

<div class="relative inline-flex shrink-0">
  {#if url}
    <img src={url} alt={name} class="{sizeClasses[size]} rounded-full object-cover ring-2 ring-[var(--dp-border)]" />
  {:else}
    <div class="{sizeClasses[size]} rounded-full bg-gradient-to-br {getColor(name)} flex items-center justify-center font-semibold text-white ring-2 ring-[var(--dp-border)]">
      {getInitials(name)}
    </div>
  {/if}

  {#if status && statusColors[status]}
    <span class="absolute -bottom-0.5 -right-0.5 w-3 h-3 rounded-full {statusColors[status]} ring-2 ring-[var(--dp-bg-card)]"></span>
  {/if}
</div>
