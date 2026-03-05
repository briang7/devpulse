<script lang="ts">
	import '../app.css';
	import { onMount } from 'svelte';
	import { fade } from 'svelte/transition';
	import { initAuth, isAuthenticated, isLoading } from '$lib/stores/auth';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import Sidebar from '$lib/components/layout/Sidebar.svelte';
	import Header from '$lib/components/layout/Header.svelte';
	import { loadNotifications } from '$lib/stores/activities';

	let { children } = $props();
	let sidebarCollapsed = $state(false);
	let mobileSidebarOpen = $state(false);
	let mounted = $state(false);

	const publicRoutes = ['/login'];

	// Close mobile sidebar on route change
	let currentPath = $derived($page.url.pathname);
	$effect(() => {
		currentPath;
		mobileSidebarOpen = false;
	});

	onMount(() => {
		initAuth();
		mounted = true;
		loadNotifications();
	});

	$effect(() => {
		if (mounted && !$isLoading && !$isAuthenticated && !publicRoutes.includes($page.url.pathname)) {
			goto('/login');
		}
	});
</script>

{#if $isLoading}
	<div class="h-screen w-screen flex items-center justify-center bg-[var(--dp-bg-dark)]">
		<div class="flex flex-col items-center gap-4 animate-scale-in">
			<div class="w-14 h-14 rounded-xl bg-gradient-to-br from-violet-500 to-blue-500 flex items-center justify-center">
				<svg class="w-8 h-8 text-white animate-pulse" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
					<path d="M13 10V3L4 14h7v7l9-11h-7z" />
				</svg>
			</div>
			<div class="flex flex-col items-center gap-2">
				<p class="text-sm font-medium text-[var(--dp-text)]">Loading DevPulse...</p>
				<div class="w-32 h-1 rounded-full bg-[var(--dp-bg-surface)] overflow-hidden">
					<div class="h-full w-1/2 rounded-full bg-gradient-to-r from-violet-500 to-blue-500 animate-[shimmer_1.2s_ease-in-out_infinite]"></div>
				</div>
			</div>
		</div>
	</div>
{:else if publicRoutes.includes($page.url.pathname)}
	{@render children()}
{:else if $isAuthenticated}
	<div class="min-h-screen bg-[var(--dp-bg-dark)]">
		<!-- Desktop sidebar -->
		<div class="hidden md:block">
			<Sidebar bind:collapsed={sidebarCollapsed} />
		</div>

		<!-- Mobile sidebar overlay -->
		{#if mobileSidebarOpen}
			<div class="md:hidden fixed inset-0 z-50">
				<!-- Backdrop -->
				<!-- svelte-ignore a11y_no_static_element_interactions -->
				<div
					class="absolute inset-0 bg-black/60 backdrop-blur-sm"
					transition:fade={{ duration: 200 }}
					onclick={() => mobileSidebarOpen = false}
					onkeydown={(e) => e.key === 'Escape' && (mobileSidebarOpen = false)}
				></div>
				<!-- Sidebar panel -->
				<div transition:fly={{ x: -280, duration: 250 }}>
					<Sidebar collapsed={false} />
				</div>
			</div>
		{/if}

		<Header {sidebarCollapsed} onMobileMenuToggle={() => mobileSidebarOpen = !mobileSidebarOpen} />

		<main
			class="pt-16 transition-all duration-300 min-h-screen md:ml-0"
			style="margin-left: {sidebarCollapsed ? '4.5rem' : '16rem'}"
		>
			<div class="p-4 md:p-6">
				{@render children()}
			</div>
		</main>
	</div>
{:else}
	<div class="h-screen w-screen flex items-center justify-center bg-[var(--dp-bg-dark)]">
		<p class="text-[var(--dp-text-muted)] animate-fade-in">Redirecting to login...</p>
	</div>
{/if}

<style>
	/* Mobile: hide desktop sidebar margin */
	@media (max-width: 767px) {
		main {
			margin-left: 0 !important;
		}
	}
</style>
