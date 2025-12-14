import { NextResponse } from 'next/server';

const API_URL = process.env.API_URL || 'http://localhost:8000';

interface BackendHealth {
  service: string;
  status: string;
  timestamp: string;
  version?: {
    rails: string;
    ruby: string;
  };
  checks?: {
    api: { status: string };
    database: { status: string };
    engines: {
      cat_content: { status: string };
    };
  };
}

export async function GET() {
  const startTime = Date.now();
  
  // Check backend API health
  let backendHealth: BackendHealth | null = null;
  let backendError: string | null = null;
  
  try {
    const response = await fetch(`${API_URL}/health`, {
      cache: 'no-store',
      signal: AbortSignal.timeout(5000), // 5 second timeout
    });
    backendHealth = await response.json();
  } catch (error) {
    backendError = error instanceof Error ? error.message : 'Unknown error';
  }

  const responseTime = Date.now() - startTime;

  const allHealthy = backendHealth?.status === 'healthy';

  return NextResponse.json({
    service: 'rampart-web',
    status: allHealthy ? 'healthy' : 'degraded',
    timestamp: new Date().toISOString(),
    version: {
      nextjs: process.env.npm_package_version || 'unknown',
      node: process.version,
    },
    checks: {
      frontend: {
        status: 'healthy',
      },
      backend: backendHealth ? {
        status: backendHealth.status,
        url: API_URL,
        responseTime: `${responseTime}ms`,
        details: backendHealth.checks,
      } : {
        status: 'unreachable',
        url: API_URL,
        error: backendError,
      },
    },
  }, {
    status: allHealthy ? 200 : 503,
  });
}


