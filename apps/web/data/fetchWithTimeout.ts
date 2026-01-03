const REQUEST_TIMEOUT_MS = 10_000;

export class ApiUnavailableError extends Error {
  constructor(message = 'Unable to reach the backend.') {
    super(message);
    this.name = 'ApiUnavailableError';
  }
}

export class ApiNotFoundError extends Error {
  constructor(message = 'Resource not found.') {
    super(message);
    this.name = 'ApiNotFoundError';
  }
}

export async function fetchWithTimeout(
  input: RequestInfo,
  init: RequestInit = {},
  timeoutMs: number = REQUEST_TIMEOUT_MS
): Promise<Response> {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    return await fetch(input, { ...init, signal: controller.signal });
  } catch (error) {
    const errorName = (error && typeof error === 'object' && 'name' in error)
      ? String(error.name)
      : '';

    if (errorName === 'AbortError') {
      throw new ApiUnavailableError('Request timed out while contacting the backend.');
    }

    throw new ApiUnavailableError('Unable to reach the backend.');
  } finally {
    clearTimeout(timeoutId);
  }
}
