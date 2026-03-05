import { writable } from 'svelte/store';
import { api } from '$lib/services/api';

export interface Discussion {
  id: string;
  teamId: string;
  projectId: string | null;
  title: string;
  content: string;
  authorId: string;
  isPinned: boolean;
  tags: string[];
  createdAt: string;
  updatedAt: string;
  replyCount: number;
  author?: {
    id: string;
    displayName: string;
    avatarUrl: string;
    email: string;
  };
  reactions?: Reaction[];
}

export interface Reply {
  id: string;
  discussionId: string;
  parentId: string | null;
  authorId: string;
  content: string;
  createdAt: string;
  author?: {
    id: string;
    displayName: string;
    avatarUrl: string;
    email: string;
  };
  reactions?: Reaction[];
}

export interface Reaction {
  id: string;
  targetType: string;
  targetId: string;
  userId: string;
  emoji: string;
}

export const discussionsStore = writable<Discussion[]>([]);
export const currentDiscussion = writable<Discussion | null>(null);
export const discussionReplies = writable<Reply[]>([]);
export const discussionsLoading = writable(false);

export async function loadDiscussions(teamId: string) {
  discussionsLoading.set(true);
  try {
    const data = await api.get<Discussion[]>(`/api/teams/${teamId}/discussions`);
    discussionsStore.set(data || []);
  } catch (e) {
    console.error('Failed to load discussions', e);
  } finally {
    discussionsLoading.set(false);
  }
}

export async function loadDiscussion(id: string) {
  try {
    const data = await api.get<{ discussion: Discussion; replies: Reply[] }>(`/api/discussions/${id}`);
    currentDiscussion.set(data.discussion);
    discussionReplies.set(data.replies || []);
  } catch (e) {
    console.error('Failed to load discussion', e);
  }
}

export async function createDiscussion(teamId: string, data: { title: string; content: string; tags?: string[] }) {
  const discussion = await api.post<Discussion>(`/api/teams/${teamId}/discussions`, data);
  discussionsStore.update(d => [discussion, ...d]);
  return discussion;
}

export async function toggleReaction(discussionId: string, emoji: string, targetType: 'discussion' | 'reply', targetId: string) {
  try {
    await api.post(`/api/discussions/${discussionId}/reactions`, { emoji, targetType, targetId });
    // Reload to get updated reactions
    await loadDiscussion(discussionId);
  } catch (e) {
    console.error('Failed to toggle reaction', e);
  }
}

export async function togglePin(id: string) {
  try {
    await api.put(`/api/discussions/${id}/pin`, {});
    currentDiscussion.update(d => d ? { ...d, isPinned: !d.isPinned } : null);
  } catch (e) {
    console.error('Failed to toggle pin', e);
  }
}
