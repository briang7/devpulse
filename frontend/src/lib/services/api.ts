import { get } from 'svelte/store';
import { authStore } from '$lib/stores/auth';

const BASE_URL = import.meta.env.PUBLIC_API_URL || '';

class ApiClient {
  private getHeaders(): HeadersInit {
    const headers: HeadersInit = {
      'Content-Type': 'application/json'
    };

    const auth = get(authStore);
    if (auth.token) {
      headers['Authorization'] = `Bearer ${auth.token}`;
    }

    return headers;
  }

  async get<T>(path: string): Promise<T> {
    const res = await fetch(`${BASE_URL}${path}`, {
      headers: this.getHeaders()
    });

    if (!res.ok) {
      throw new Error(`GET ${path} failed: ${res.status}`);
    }

    return res.json();
  }

  async post<T>(path: string, body: unknown): Promise<T> {
    const res = await fetch(`${BASE_URL}${path}`, {
      method: 'POST',
      headers: this.getHeaders(),
      body: JSON.stringify(body)
    });

    if (!res.ok) {
      throw new Error(`POST ${path} failed: ${res.status}`);
    }

    return res.json();
  }

  async put<T>(path: string, body: unknown): Promise<T> {
    const res = await fetch(`${BASE_URL}${path}`, {
      method: 'PUT',
      headers: this.getHeaders(),
      body: JSON.stringify(body)
    });

    if (!res.ok) {
      throw new Error(`PUT ${path} failed: ${res.status}`);
    }

    return res.json();
  }

  async delete(path: string): Promise<void> {
    const res = await fetch(`${BASE_URL}${path}`, {
      method: 'DELETE',
      headers: this.getHeaders()
    });

    if (!res.ok) {
      throw new Error(`DELETE ${path} failed: ${res.status}`);
    }
  }
}

export const api = new ApiClient();
