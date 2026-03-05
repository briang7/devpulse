import { writable } from 'svelte/store';
import { api } from '$lib/services/api';

export interface Room {
  id: string;
  name: string;
  description: string;
  language: string;
  teamId: string;
  projectId: string | null;
  createdBy: string;
  isActive: boolean;
  participants: number;
  createdAt: string;
  updatedAt: string;
  team?: {
    id: string;
    name: string;
    slug: string;
  };
}

export const roomsStore = writable<Room[]>([]);
export const currentRoom = writable<Room | null>(null);
export const roomsLoading = writable(false);

export async function loadRooms() {
  roomsLoading.set(true);
  try {
    const rooms = await api.get<Room[]>('/api/rooms');
    roomsStore.set(rooms || []);
  } catch (e) {
    console.error('Failed to load rooms', e);
  } finally {
    roomsLoading.set(false);
  }
}

export async function loadRoom(id: string) {
  try {
    const room = await api.get<Room>(`/api/rooms/${id}`);
    currentRoom.set(room);
    return room;
  } catch (e) {
    console.error('Failed to load room', e);
    return null;
  }
}

export async function createRoom(data: { name: string; description: string; language: string; teamId: string }) {
  const room = await api.post<Room>('/api/rooms', data);
  roomsStore.update(rooms => [room, ...rooms]);
  return room;
}
