import { writable } from 'svelte/store';
import { api } from '$lib/services/api';

export interface Document {
  id: string;
  teamId: string;
  parentId: string | null;
  title: string;
  slug: string;
  content: string;
  authorId: string;
  sortOrder: number;
  createdAt: string;
  updatedAt: string;
  author?: {
    id: string;
    displayName: string;
    avatarUrl: string;
  };
  children?: Document[];
}

export interface DocumentVersion {
  id: string;
  documentId: string;
  title: string;
  content: string;
  authorId: string;
  version: number;
  createdAt: string;
  author?: {
    id: string;
    displayName: string;
    avatarUrl: string;
  };
}

export const documentsStore = writable<Document[]>([]);
export const currentDocument = writable<Document | null>(null);
export const documentVersions = writable<DocumentVersion[]>([]);
export const documentsLoading = writable(false);

export async function loadDocuments(teamId: string) {
  documentsLoading.set(true);
  try {
    const docs = await api.get<Document[]>(`/api/teams/${teamId}/docs`);
    documentsStore.set(docs || []);
  } catch (e) {
    console.error('Failed to load documents', e);
  } finally {
    documentsLoading.set(false);
  }
}

export async function loadDocument(id: string) {
  try {
    const doc = await api.get<Document>(`/api/docs/${id}`);
    currentDocument.set(doc);
  } catch (e) {
    console.error('Failed to load document', e);
  }
}

export async function loadVersions(docId: string) {
  try {
    const versions = await api.get<DocumentVersion[]>(`/api/docs/${docId}/versions`);
    documentVersions.set(versions || []);
  } catch (e) {
    console.error('Failed to load versions', e);
  }
}

export async function updateDocument(id: string, data: { title?: string; content?: string }) {
  const doc = await api.put<Document>(`/api/docs/${id}`, data);
  currentDocument.set(doc);
  return doc;
}

export async function createVersion(docId: string, data: { title: string; content: string }) {
  const version = await api.post<DocumentVersion>(`/api/docs/${docId}/versions`, data);
  documentVersions.update(v => [version, ...v]);
  return version;
}

export async function createDocument(teamId: string, data: { title: string; content: string; parentId?: string }) {
  const doc = await api.post<Document>(`/api/teams/${teamId}/docs`, data);
  documentsStore.update(d => [...d, doc]);
  return doc;
}

// Build tree structure from flat list
export function buildDocTree(docs: Document[]): Document[] {
  const map = new Map<string, Document>();
  const roots: Document[] = [];

  docs.forEach(d => map.set(d.id, { ...d, children: [] }));

  map.forEach(doc => {
    if (doc.parentId && map.has(doc.parentId)) {
      map.get(doc.parentId)!.children!.push(doc);
    } else {
      roots.push(doc);
    }
  });

  return roots;
}
