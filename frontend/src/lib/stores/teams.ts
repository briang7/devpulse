import { writable, derived } from 'svelte/store';
import { api } from '$lib/services/api';

export interface Team {
  id: string;
  name: string;
  slug: string;
  description: string;
  avatarUrl: string;
  createdBy: string;
  memberCount: number;
  createdAt: string;
}

export interface TeamMember {
  teamId: string;
  userId: string;
  role: string;
  joinedAt: string;
  user?: {
    id: string;
    displayName: string;
    avatarUrl: string;
    email: string;
    status: string;
  };
}

export interface Project {
  id: string;
  teamId: string;
  name: string;
  description: string;
  language: string;
  repoUrl: string;
  createdAt: string;
}

export const teamsStore = writable<Team[]>([]);
export const currentTeam = writable<Team | null>(null);
export const teamMembers = writable<TeamMember[]>([]);
export const projects = writable<Project[]>([]);
export const teamsLoading = writable(false);

export async function loadTeams() {
  teamsLoading.set(true);
  try {
    const teams = await api.get<Team[]>('/api/teams');
    teamsStore.set(teams || []);
  } catch (e) {
    console.error('Failed to load teams', e);
  } finally {
    teamsLoading.set(false);
  }
}

export async function loadTeam(id: string) {
  try {
    const data = await api.get<{ team: Team; members: TeamMember[] }>(`/api/teams/${id}`);
    currentTeam.set(data.team);
    teamMembers.set(data.members || []);
  } catch (e) {
    console.error('Failed to load team', e);
  }
}

export async function createProject(teamId: string, data: { name: string; description: string; language: string; repoUrl: string }) {
  const project = await api.post<Project>(`/api/teams/${teamId}/projects`, data);
  projects.update(p => [...p, project]);
  return project;
}

export async function createTeam(data: { name: string; description: string }) {
  const team = await api.post<Team>('/api/teams', data);
  teamsStore.update(t => [...t, team]);
  return team;
}

export async function addMember(teamId: string, data: { email: string; role?: string }) {
  await api.post(`/api/teams/${teamId}/members`, data);
  await loadTeam(teamId);
}

export async function updateMemberRole(teamId: string, userId: string, role: string) {
  await api.put(`/api/teams/${teamId}/members/${userId}`, { role });
  teamMembers.update(members =>
    members.map(m => m.userId === userId ? { ...m, role } : m)
  );
}

export async function removeMember(teamId: string, userId: string) {
  await api.delete(`/api/teams/${teamId}/members/${userId}`);
  teamMembers.update(members => members.filter(m => m.userId !== userId));
}

export async function loadProjects(teamId: string) {
  try {
    const data = await api.get<Project[]>(`/api/teams/${teamId}/projects`);
    projects.set(data || []);
  } catch (e) {
    console.error('Failed to load projects', e);
    projects.set([]);
  }
}
