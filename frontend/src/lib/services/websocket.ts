import { get } from 'svelte/store';
import { authStore } from '$lib/stores/auth';

export type MessageHandler = (data: any) => void;

export class WebSocketClient {
  private ws: WebSocket | null = null;
  private url: string;
  private handlers = new Map<string, Set<MessageHandler>>();
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 10;
  private reconnectTimer: ReturnType<typeof setTimeout> | null = null;
  private _connected = false;

  constructor(roomId: string) {
    const auth = get(authStore);
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const host = window.location.host;
    const name = auth.user?.displayName || 'Anonymous';
    const color = this.getRandomColor();
    this.url = `${protocol}//${host}/ws/${roomId}?token=${auth.token}&name=${encodeURIComponent(name)}&color=${encodeURIComponent(color)}`;
  }

  get connected() {
    return this._connected;
  }

  connect() {
    try {
      this.ws = new WebSocket(this.url);

      this.ws.onopen = () => {
        this._connected = true;
        this.reconnectAttempts = 0;
        this.emit('connected', {});
      };

      this.ws.onmessage = (event) => {
        try {
          // Check if binary (Yjs update)
          if (event.data instanceof Blob) {
            this.emit('yjs_update', event.data);
            return;
          }
          const msg = JSON.parse(event.data);
          this.emit(msg.type, msg);
        } catch {
          // Binary message
          this.emit('binary', event.data);
        }
      };

      this.ws.onclose = () => {
        this._connected = false;
        this.emit('disconnected', {});
        this.attemptReconnect();
      };

      this.ws.onerror = () => {
        this._connected = false;
      };
    } catch (e) {
      console.error('WebSocket connection failed', e);
      this.attemptReconnect();
    }
  }

  private attemptReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) return;

    const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000);
    this.reconnectAttempts++;

    this.reconnectTimer = setTimeout(() => {
      this.connect();
    }, delay);
  }

  send(type: string, payload: any) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify({ type, payload }));
    }
  }

  sendBinary(data: Uint8Array) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(data);
    }
  }

  on(type: string, handler: MessageHandler) {
    if (!this.handlers.has(type)) {
      this.handlers.set(type, new Set());
    }
    this.handlers.get(type)!.add(handler);
    return () => this.handlers.get(type)?.delete(handler);
  }

  private emit(type: string, data: any) {
    this.handlers.get(type)?.forEach(handler => handler(data));
  }

  disconnect() {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
    }
    this.maxReconnectAttempts = 0; // Prevent reconnection
    this.ws?.close();
    this.ws = null;
    this._connected = false;
  }

  private getRandomColor(): string {
    const colors = ['#7c3aed', '#2563eb', '#059669', '#d97706', '#dc2626', '#db2777', '#7c3aed', '#4f46e5'];
    return colors[Math.floor(Math.random() * colors.length)];
  }
}
