import { writable, derived } from 'svelte/store';

export interface User {
  id: string;
  firebaseUid: string;
  email: string;
  displayName: string;
  avatarUrl: string;
  status: string;
  bio: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  loading: boolean;
  initialized: boolean;
}

const initialState: AuthState = {
  user: null,
  token: null,
  loading: true,
  initialized: false
};

export const authStore = writable<AuthState>(initialState);
export const currentUser = derived(authStore, ($auth) => $auth.user);
export const isAuthenticated = derived(authStore, ($auth) => !!$auth.user);
export const isLoading = derived(authStore, ($auth) => $auth.loading);

// Demo users for development
const demoUsers: Record<string, User> = {
  'demo-alex': {
    id: '00000000-0000-0000-0000-000000000001',
    firebaseUid: 'demo-alex',
    email: 'alex@devpulse.dev',
    displayName: 'Alex Rivera',
    avatarUrl: '',
    status: 'online',
    bio: 'Full-stack developer. Rust enthusiast.'
  },
  'demo-sam': {
    id: '00000000-0000-0000-0000-000000000002',
    firebaseUid: 'demo-sam',
    email: 'sam@devpulse.dev',
    displayName: 'Sam Chen',
    avatarUrl: '',
    status: 'online',
    bio: 'Backend engineer. Go & Kubernetes.'
  },
  'demo-jordan': {
    id: '00000000-0000-0000-0000-000000000003',
    firebaseUid: 'demo-jordan',
    email: 'jordan@devpulse.dev',
    displayName: 'Jordan Park',
    avatarUrl: '',
    status: 'away',
    bio: 'DevOps lead. Infrastructure as code.'
  }
};

export function loginWithDemo(uid: string) {
  const user = demoUsers[uid];
  if (user) {
    authStore.set({
      user,
      token: `dev:${uid}`,
      loading: false,
      initialized: true
    });
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('devpulse_demo_uid', uid);
    }
  }
}

export function logout() {
  authStore.set({ ...initialState, loading: false, initialized: true });
  if (typeof localStorage !== 'undefined') {
    localStorage.removeItem('devpulse_demo_uid');
    localStorage.removeItem('devpulse_profile');
  }
}

export function updateProfile(updates: Partial<User>) {
  authStore.update(state => {
    if (!state.user) return state;
    const updated = { ...state.user, ...updates };
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('devpulse_profile', JSON.stringify(updated));
    }
    return { ...state, user: updated };
  });
}

export function initAuth() {
  if (typeof localStorage !== 'undefined') {
    const savedUid = localStorage.getItem('devpulse_demo_uid');
    if (savedUid && demoUsers[savedUid]) {
      loginWithDemo(savedUid);
      // Apply any saved profile overrides
      const savedProfile = localStorage.getItem('devpulse_profile');
      if (savedProfile) {
        try {
          const overrides = JSON.parse(savedProfile);
          if (overrides.firebaseUid === savedUid) {
            authStore.update(state => ({
              ...state,
              user: state.user ? { ...state.user, ...overrides } : state.user
            }));
          }
        } catch { /* ignore */ }
      }
      return;
    }
  }
  authStore.set({ ...initialState, loading: false, initialized: true });
}

export function getDemoUsers() {
  return Object.entries(demoUsers).map(([uid, user]) => ({ uid, ...user }));
}
