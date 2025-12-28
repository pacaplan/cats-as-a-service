// API client for the Cat Content backend

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

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

/**
 * Fetch all published cat listings from the catalog
 */
export async function fetchCatalog(): Promise<CatalogResponse> {
  const response = await fetch(`${API_BASE_URL}/api/catalog`, {
    cache: 'no-store', // Always fetch fresh data
    headers: {
      'Accept': 'application/json',
    },
  });

  if (!response.ok) {
    const error: ApiError = await response.json();
    throw new Error(error.message || 'Failed to fetch catalog');
  }

  return response.json();
}

/**
 * Fetch a single cat listing by slug
 */
export async function fetchCatListing(slug: string): Promise<CatListing> {
  const response = await fetch(`${API_BASE_URL}/api/catalog/${slug}`, {
    cache: 'no-store',
    headers: {
      'Accept': 'application/json',
    },
  });

  if (!response.ok) {
    const error: ApiError = await response.json();
    throw new Error(error.message || 'Cat listing not found');
  }

  return response.json();
}


