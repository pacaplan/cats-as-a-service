// API client for the Cat Content backend

import { ApiNotFoundError, fetchWithTimeout } from './fetchWithTimeout';

const DEFAULT_API_URL = 'http://localhost:8000';
const API_BASE_URL = typeof window === 'undefined'
  ? (process.env.API_URL || process.env.NEXT_PUBLIC_API_URL || DEFAULT_API_URL)
  : (process.env.NEXT_PUBLIC_API_URL || DEFAULT_API_URL);

export interface CatPrice {
  cents: number;
  currency: string;
  formatted: string;
}

export interface CatImage {
  url: string | null;
  alt: string | null;
}

export interface CatListing {
  id: string;
  name: string;
  slug: string;
  description: string;
  price: CatPrice;
  image: CatImage;
  tags: string[];
}

export interface CatalogResponse {
  listings: CatListing[];
  count: number;
}

export interface ApiError {
  error: string;
  message: string;
}

async function parseApiError(response: Response): Promise<ApiError | null> {
  try {
    return await response.json();
  } catch (error) {
    return null;
  }
}

/**
 * Fetch all published cat listings from the catalog
 */
export async function fetchCatalog(): Promise<CatalogResponse> {
  const response = await fetchWithTimeout(`${API_BASE_URL}/api/catalog`, {
    cache: 'no-store', // Always fetch fresh data
    headers: {
      'Accept': 'application/json',
    },
  });

  if (!response.ok) {
    const error = await parseApiError(response);
    throw new Error(error?.message || `Failed to fetch catalog (${response.status})`);
  }

  return response.json();
}

/**
 * Fetch a single cat listing by slug
 */
export async function fetchCatListing(slug: string): Promise<CatListing> {
  const response = await fetchWithTimeout(`${API_BASE_URL}/api/catalog/${slug}`, {
    cache: 'no-store',
    headers: {
      'Accept': 'application/json',
    },
  });

  if (response.status === 404) {
    throw new ApiNotFoundError('Cat listing not found');
  }

  if (!response.ok) {
    const error = await parseApiError(response);
    throw new Error(error?.message || `Cat listing not found (${response.status})`);
  }

  return response.json();
}
