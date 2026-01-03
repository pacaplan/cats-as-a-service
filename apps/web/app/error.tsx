'use client';

import React, { useEffect } from 'react';
import Header from '@/components/layout/Header';
import Button from '@/components/ui/Button';

interface ErrorPageProps {
  error: Error & { digest?: string };
  reset: () => void;
}

export default function ErrorPage({ error, reset }: ErrorPageProps) {
  useEffect(() => {
    console.error('App route error:', error);
  }, [error]);

  return (
    <div className="bg-background text-foreground min-h-screen flex flex-col">
      <div className="max-w-[1120px] mx-auto p-[24px_32px_40px_32px] flex flex-col gap-6">
        <Header />
        <main className="flex flex-col items-center justify-center text-center gap-4 py-16">
          <div className="text-4xl font-semibold">!</div>
          <h1 className="text-2xl font-bold">We can’t reach the cat-alog right now</h1>
          <p className="text-sm text-muted-foreground max-w-[520px]">
            The backend took too long to respond or is offline. Please try again in a moment.
          </p>
          <div className="flex items-center gap-3">
            <Button variant="primary" onClick={reset} className="px-4 py-2">
              Try again
            </Button>
            <button
              className="rounded-md px-4 py-2 text-[13px] font-medium bg-transparent text-foreground cursor-pointer"
              onClick={() => window.location.reload()}
            >
              Reload page
            </button>
          </div>
          {error.message && (
            <div className="text-xs text-muted-foreground">
              {error.message}
            </div>
          )}
        </main>
      </div>
    </div>
  );
}
