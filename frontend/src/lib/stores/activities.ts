import { writable } from 'svelte/store';
import { api } from '$lib/services/api';

export interface Activity {
  id: string;
  teamId: string;
  actorId: string;
  action: string;
  targetType: string;
  targetId: string;
  targetName: string;
  metadata: string;
  createdAt: string;
  actor?: {
    id: string;
    displayName: string;
    avatarUrl: string;
  };
}

export interface Notification {
  id: string;
  userId: string;
  type: string;
  title: string;
  content: string;
  linkUrl: string;
  isRead: boolean;
  createdAt: string;
}

export const activitiesStore = writable<Activity[]>([]);
export const notificationsStore = writable<Notification[]>([]);
export const unreadCount = writable(0);
export const activitiesLoading = writable(false);

export async function loadActivities(limit = 20, offset = 0) {
  activitiesLoading.set(true);
  try {
    const data = await api.get<Activity[]>(`/api/activities?limit=${limit}&offset=${offset}`);
    if (offset === 0) {
      activitiesStore.set(data || []);
    } else {
      activitiesStore.update(a => [...a, ...(data || [])]);
    }
  } catch (e) {
    console.error('Failed to load activities', e);
  } finally {
    activitiesLoading.set(false);
  }
}

export async function loadNotifications() {
  try {
    const data = await api.get<Notification[]>('/api/notifications');
    notificationsStore.set(data || []);
    unreadCount.set((data || []).filter(n => !n.isRead).length);
  } catch (e) {
    console.error('Failed to load notifications', e);
  }
}

export async function markAsRead(id: string) {
  try {
    await api.put(`/api/notifications/${id}/read`, {});
    notificationsStore.update(notes =>
      notes.map(n => n.id === id ? { ...n, isRead: true } : n)
    );
    unreadCount.update(n => Math.max(0, n - 1));
  } catch (e) {
    console.error('Failed to mark notification as read', e);
  }
}
