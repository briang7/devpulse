<script lang="ts">
  let { text = '', variant = 'default' as 'default' | 'primary' | 'success' | 'warning' | 'danger', size = 'sm' as 'sm' | 'md' } = $props();

  const variants: Record<string, string> = {
    default: 'bg-[var(--dp-bg-surface)] text-[var(--dp-text-muted)]',
    primary: 'bg-violet-500/20 text-violet-400',
    success: 'bg-emerald-500/20 text-emerald-400',
    warning: 'bg-amber-500/20 text-amber-400',
    danger: 'bg-red-500/20 text-red-400'
  };

  const sizes: Record<string, string> = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-3 py-1 text-sm'
  };
</script>

<span class="inline-flex items-center rounded-full font-medium {variants[variant]} {sizes[size]}">
  {text}
</span>
