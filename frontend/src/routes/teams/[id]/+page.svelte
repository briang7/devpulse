<script lang="ts">
  import { onMount } from 'svelte';
  import { slide } from 'svelte/transition';
  import { page } from '$app/stores';
  import { currentTeam, teamMembers, projects, loadTeam, loadProjects, createProject, addMember, updateMemberRole, removeMember } from '$lib/stores/teams';
  import { currentUser } from '$lib/stores/auth';
  import { timeAgo } from '$lib/utils/format';
  import Avatar from '$lib/components/shared/Avatar.svelte';
  import Badge from '$lib/components/shared/Badge.svelte';
  import Modal from '$lib/components/shared/Modal.svelte';

  let expandedProject = $state<string | null>(null);
  let showCreateModal = $state(false);
  let showInviteModal = $state(false);
  let newName = $state('');
  let newDescription = $state('');
  let newLanguage = $state('javascript');
  let newRepoUrl = $state('');
  let creating = $state(false);
  let inviteEmail = $state('');
  let inviteRole = $state('member');
  let inviting = $state(false);

  const languages = ['javascript', 'typescript', 'python', 'go', 'rust', 'java', 'c#', 'ruby', 'php', 'swift'];
  const roles = ['admin', 'member', 'guest'];

  function toggleProject(id: string) {
    expandedProject = expandedProject === id ? null : id;
  }

  async function handleCreate() {
    if (!newName.trim()) return;
    creating = true;
    try {
      await createProject($page.params.id, {
        name: newName,
        description: newDescription,
        language: newLanguage,
        repoUrl: newRepoUrl
      });
      newName = '';
      newDescription = '';
      newLanguage = 'javascript';
      newRepoUrl = '';
      showCreateModal = false;
    } catch (e) {
      console.error('Failed to create project', e);
    } finally {
      creating = false;
    }
  }

  async function handleInvite() {
    if (!inviteEmail.trim()) return;
    inviting = true;
    try {
      await addMember($page.params.id, { email: inviteEmail, role: inviteRole });
      inviteEmail = '';
      inviteRole = 'member';
      showInviteModal = false;
    } catch (e) {
      console.error('Failed to invite member', e);
    } finally {
      inviting = false;
    }
  }

  async function handleRoleChange(userId: string, newRole: string) {
    try {
      await updateMemberRole($page.params.id, userId, newRole);
    } catch (e) {
      console.error('Failed to update role', e);
    }
  }

  async function handleRemoveMember(userId: string) {
    try {
      await removeMember($page.params.id, userId);
    } catch (e) {
      console.error('Failed to remove member', e);
    }
  }

  onMount(async () => {
    await loadTeam($page.params.id);
    loadProjects($page.params.id);
  });

  const roleColors: Record<string, 'primary' | 'success' | 'warning' | 'default'> = {
    owner: 'warning',
    admin: 'primary',
    member: 'default',
    guest: 'default'
  };
</script>

<div class="max-w-6xl mx-auto">
  {#if $currentTeam}
    <!-- Team header -->
    <div class="mb-8 animate-fade-in-up">
      <a href="/teams" class="text-sm text-violet-400 hover:text-violet-300 mb-3 inline-flex items-center gap-1 group">
        <svg class="w-4 h-4 group-hover:-translate-x-0.5 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
        </svg>
        Back to teams
      </a>
      <div class="flex items-center gap-4 mt-2">
        <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-violet-500 to-blue-500 flex items-center justify-center text-2xl text-white font-bold">
          {$currentTeam.name[0]}
        </div>
        <div>
          <h1 class="text-2xl font-bold text-[var(--dp-text)]">{$currentTeam.name}</h1>
          <p class="text-[var(--dp-text-muted)]">{$currentTeam.description || 'No description'}</p>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Members -->
      <div class="lg:col-span-1 animate-fade-in-up" style="animation-delay: 100ms">
        <div class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-5">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold text-[var(--dp-text)]">Members ({$teamMembers.length})</h2>
            <button
              onclick={() => showInviteModal = true}
              class="px-2.5 py-1 rounded-lg bg-violet-600 hover:bg-violet-500 text-white text-xs font-medium transition-colors flex items-center gap-1"
            >
              <svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
              </svg>
              Invite
            </button>
          </div>
          <div class="space-y-3 stagger-children">
            {#each $teamMembers as member}
              <div class="flex items-center gap-3 group">
                <Avatar name={member.user?.displayName || 'Unknown'} size="sm" status={member.user?.status || 'offline'} />
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-[var(--dp-text)] truncate">{member.user?.displayName}</p>
                  <p class="text-xs text-[var(--dp-text-muted)]">{member.user?.email}</p>
                </div>
                {#if member.role === 'owner'}
                  <Badge text="owner" variant="warning" />
                {:else}
                  <select
                    value={member.role}
                    onchange={(e) => handleRoleChange(member.userId, (e.target as HTMLSelectElement).value)}
                    class="text-xs bg-[var(--dp-bg-surface)] border border-[var(--dp-border)] rounded-md px-1.5 py-0.5 text-[var(--dp-text-muted)] focus:outline-none focus:ring-1 focus:ring-violet-500/50 cursor-pointer"
                  >
                    {#each roles as role}
                      <option value={role}>{role}</option>
                    {/each}
                  </select>
                  <button
                    onclick={() => handleRemoveMember(member.userId)}
                    class="opacity-0 group-hover:opacity-100 p-1 rounded text-red-400 hover:bg-red-500/10 transition-all"
                    title="Remove member"
                  >
                    <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                {/if}
              </div>
            {/each}
          </div>
        </div>
      </div>

      <!-- Projects -->
      <div class="lg:col-span-2 animate-fade-in-up" style="animation-delay: 200ms">
        <div class="rounded-xl bg-[var(--dp-bg-card)] border border-[var(--dp-border)] p-5">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold text-[var(--dp-text)]">Projects ({$projects.length})</h2>
            <button onclick={() => showCreateModal = true} class="px-3 py-1.5 rounded-lg bg-violet-600 hover:bg-violet-500 text-white text-xs font-medium transition-colors flex items-center gap-1.5">
              <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
              </svg>
              Add Project
            </button>
          </div>
          {#if $projects.length === 0}
            <div class="text-center py-10">
              <div class="w-12 h-12 rounded-xl bg-[var(--dp-bg-surface)] flex items-center justify-center mx-auto mb-3">
                <svg class="w-6 h-6 text-[var(--dp-text-muted)]" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 12.75V12A2.25 2.25 0 014.5 9.75h15A2.25 2.25 0 0121.75 12v.75m-8.69-6.44l-2.12-2.12a1.5 1.5 0 00-1.061-.44H4.5A2.25 2.25 0 002.25 6v12a2.25 2.25 0 002.25 2.25h15A2.25 2.25 0 0021.75 18V9a2.25 2.25 0 00-2.25-2.25h-5.379a1.5 1.5 0 01-1.06-.44z" />
                </svg>
              </div>
              <p class="text-sm text-[var(--dp-text-muted)] mb-3">No projects yet</p>
              <button onclick={() => showCreateModal = true} class="text-sm text-violet-400 hover:text-violet-300 transition-colors">
                Create your first project
              </button>
            </div>
          {:else}
            <div class="space-y-3">
              {#each $projects as project}
                <button
                  type="button"
                  onclick={() => toggleProject(project.id)}
                  class="w-full text-left rounded-lg border border-[var(--dp-border)] hover:border-violet-500/30 hover:bg-white/[0.02] transition-all duration-200 cursor-pointer"
                >
                  <div class="flex items-center gap-4 p-4">
                    <div class="w-10 h-10 rounded-lg bg-[var(--dp-bg-surface)] flex items-center justify-center shrink-0">
                      <svg class="w-5 h-5 text-[var(--dp-text-muted)]" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 12.75V12A2.25 2.25 0 014.5 9.75h15A2.25 2.25 0 0121.75 12v.75m-8.69-6.44l-2.12-2.12a1.5 1.5 0 00-1.061-.44H4.5A2.25 2.25 0 002.25 6v12a2.25 2.25 0 002.25 2.25h15A2.25 2.25 0 0021.75 18V9a2.25 2.25 0 00-2.25-2.25h-5.379a1.5 1.5 0 01-1.06-.44z" />
                      </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                      <h3 class="font-medium text-[var(--dp-text)]">{project.name}</h3>
                      <p class="text-sm text-[var(--dp-text-muted)] truncate">{project.description || 'No description'}</p>
                    </div>
                    {#if project.language}
                      <Badge text={project.language} variant="primary" />
                    {/if}
                    <svg class="w-4 h-4 text-[var(--dp-text-muted)] shrink-0 transition-transform duration-200 {expandedProject === project.id ? 'rotate-180' : ''}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 8.25l-7.5 7.5-7.5-7.5" />
                    </svg>
                  </div>
                  {#if expandedProject === project.id}
                    <div class="px-4 pb-4 pt-0 border-t border-[var(--dp-border)]" transition:slide={{ duration: 200 }}>
                      <div class="pt-3 space-y-2">
                        <p class="text-sm text-[var(--dp-text)]">{project.description || 'No description provided.'}</p>
                        <div class="flex items-center flex-wrap gap-3 text-xs text-[var(--dp-text-muted)]">
                          {#if project.language}
                            <span class="flex items-center gap-1">
                              <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
                              </svg>
                              {project.language}
                            </span>
                          {/if}
                          {#if project.repoUrl}
                            <a href={project.repoUrl} target="_blank" rel="noopener noreferrer" onclick={(e) => e.stopPropagation()} class="flex items-center gap-1 text-violet-400 hover:text-violet-300">
                              <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M13.19 8.688a4.5 4.5 0 011.242 7.244l-4.5 4.5a4.5 4.5 0 01-6.364-6.364l1.757-1.757m9.86-3.553a4.5 4.5 0 00-6.364-6.364L4.757 8.757a4.5 4.5 0 006.364 6.364l4.5-4.5z" />
                              </svg>
                              Repository
                            </a>
                          {/if}
                          <span class="flex items-center gap-1">
                            <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                              <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 11.25v7.5" />
                            </svg>
                            Created {timeAgo(project.createdAt)}
                          </span>
                        </div>
                      </div>
                    </div>
                  {/if}
                </button>
              {/each}
            </div>
          {/if}
        </div>
      </div>
    </div>
  {:else}
    <div class="flex items-center justify-center py-16">
      <p class="text-[var(--dp-text-muted)]">Loading team...</p>
    </div>
  {/if}
</div>

<!-- Add Project Modal -->
<Modal bind:open={showCreateModal} title="Add Project">
  <form onsubmit={(e) => { e.preventDefault(); handleCreate(); }} class="space-y-4">
    <div>
      <label for="proj-name" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Name</label>
      <input id="proj-name" type="text" bind:value={newName} placeholder="e.g. Frontend App" required
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50" />
    </div>
    <div>
      <label for="proj-desc" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Description</label>
      <textarea id="proj-desc" bind:value={newDescription} placeholder="What is this project about?" rows="2"
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50 resize-none"></textarea>
    </div>
    <div>
      <label for="proj-lang" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Language</label>
      <select id="proj-lang" bind:value={newLanguage}
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] focus:outline-none focus:ring-2 focus:ring-violet-500/50">
        {#each languages as lang}
          <option value={lang}>{lang.charAt(0).toUpperCase() + lang.slice(1)}</option>
        {/each}
      </select>
    </div>
    <div>
      <label for="proj-repo" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Repository URL <span class="text-[var(--dp-text-muted)]">(optional)</span></label>
      <input id="proj-repo" type="url" bind:value={newRepoUrl} placeholder="https://github.com/..."
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50" />
    </div>
    <div class="mt-5">
      <button type="submit" disabled={creating || !newName.trim()}
        class="w-full py-2.5 rounded-lg bg-violet-600 hover:bg-violet-500 disabled:opacity-50 disabled:cursor-not-allowed text-white text-sm font-medium transition-colors">
        {creating ? 'Creating...' : 'Add Project'}
      </button>
    </div>
  </form>
</Modal>

<!-- Invite Member Modal -->
<Modal bind:open={showInviteModal} title="Invite Member">
  <form onsubmit={(e) => { e.preventDefault(); handleInvite(); }} class="space-y-4">
    <div>
      <label for="invite-email" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Email</label>
      <input id="invite-email" type="email" bind:value={inviteEmail} placeholder="user@example.com" required
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] placeholder:text-[var(--dp-text-muted)] focus:outline-none focus:ring-2 focus:ring-violet-500/50" />
    </div>
    <div>
      <label for="invite-role" class="block text-sm font-medium text-[var(--dp-text-muted)] mb-1.5">Role</label>
      <select id="invite-role" bind:value={inviteRole}
        class="w-full px-4 py-2.5 rounded-lg bg-[var(--dp-bg-dark)] border border-[var(--dp-border)] text-sm text-[var(--dp-text)] focus:outline-none focus:ring-2 focus:ring-violet-500/50">
        {#each roles as role}
          <option value={role}>{role.charAt(0).toUpperCase() + role.slice(1)}</option>
        {/each}
      </select>
    </div>
    <div class="mt-5">
      <button type="submit" disabled={inviting || !inviteEmail.trim()}
        class="w-full py-2.5 rounded-lg bg-violet-600 hover:bg-violet-500 disabled:opacity-50 disabled:cursor-not-allowed text-white text-sm font-medium transition-colors">
        {inviting ? 'Inviting...' : 'Send Invite'}
      </button>
    </div>
  </form>
</Modal>
