// Authentication API client for shopper registration and login

import { fetchWithTimeout } from './fetchWithTimeout';

const DEFAULT_API_URL = 'http://localhost:8000';
const API_BASE_URL = typeof window === 'undefined'
  ? (process.env.API_URL || process.env.NEXT_PUBLIC_API_URL || DEFAULT_API_URL)
  : (process.env.NEXT_PUBLIC_API_URL || DEFAULT_API_URL);

export interface User {
  id: string;
  email: string;
  name: string;
  email_verified: boolean;
  created_at: string;
}

export interface RegisterRequest {
  user: {
    email: string;
    password: string;
    password_confirmation: string;
    name: string;
  };
}

export interface LoginRequest {
  user: {
    email: string;
    password: string;
  };
}

export interface ValidationError {
  errors: {
    [field: string]: string[];
  };
}

export interface AuthError {
  error: string;
}

/**
 * Register a new shopper account
 * POST /api/users
 */
export async function registerUser(data: RegisterRequest): Promise<User> {
  const response = await fetchWithTimeout(`${API_BASE_URL}/api/users`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    credentials: 'include', // Important for session cookies
    body: JSON.stringify(data),
  });

  if (!response.ok) {
    if (response.status === 422) {
      const errorData: ValidationError = await response.json();
      throw { status: 422, errors: errorData.errors };
    }
    // Include status code for better error handling
    throw { status: response.status, message: `Registration failed (${response.status})` };
  }

  return response.json();
}

/**
 * Sign in an existing shopper
 * POST /api/users/sign_in
 */
export async function loginUser(data: LoginRequest): Promise<User> {
  const response = await fetchWithTimeout(`${API_BASE_URL}/api/users/sign_in`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    credentials: 'include', // Important for session cookies
    body: JSON.stringify(data),
  });

  if (!response.ok) {
    if (response.status === 401) {
      const errorData: AuthError = await response.json();
      throw { status: 401, error: errorData.error };
    }
    throw new Error('Login failed');
  }

  return response.json();
}

/**
 * Sign out the current shopper
 * DELETE /api/users/sign_out
 */
export async function logoutUser(): Promise<void> {
  const response = await fetchWithTimeout(`${API_BASE_URL}/api/users/sign_out`, {
    method: 'DELETE',
    headers: {
      'Accept': 'application/json',
    },
    credentials: 'include',
  });

  if (!response.ok) {
    throw new Error('Logout failed');
  }
}

/**
 * Get the currently authenticated user
 * This will be used to check session status on app mount
 */
export async function getCurrentUser(): Promise<User | null> {
  try {
    const response = await fetchWithTimeout(`${API_BASE_URL}/api/users/current`, {
      headers: {
        'Accept': 'application/json',
      },
      credentials: 'include',
    });

    if (!response.ok) {
      return null;
    }

    return response.json();
  } catch (error) {
    return null;
  }
}
