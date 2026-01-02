'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import FormInput from './FormInput';
import { useAuth } from '@/contexts/AuthContext';

export default function LoginForm() {
  const { login } = useAuth();
  const [isLoading, setIsLoading] = useState(false);
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });
  const [error, setError] = useState<string>('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      await login(formData.email, formData.password);
      // Success - the AuthContext will handle redirect
    } catch (error: any) {
      if (error.status === 401) {
        setError(error.error || 'Invalid email or password');
      } else {
        setError('Login failed. Please try again.');
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="max-w-[460px] mx-auto bg-card rounded-lg border border-[rgba(31,27,36,0.08)] p-6">
      {error && (
        <div className="bg-destructive/10 border border-destructive/20 rounded-md p-3 mb-4 text-sm text-destructive">
          {error}
        </div>
      )}

      <FormInput
        label="Email"
        type="email"
        value={formData.email}
        onChange={(value) => setFormData({ ...formData, email: value })}
        placeholder="your@email.com"
        required
        autoComplete="email"
      />

      <FormInput
        label="Password"
        type="password"
        value={formData.password}
        onChange={(value) => setFormData({ ...formData, password: value })}
        placeholder="Your password"
        required
        autoComplete="current-password"
      />

      <button
        type="submit"
        disabled={isLoading}
        className="w-full mt-2 rounded-md px-2.5 py-2 text-[13px] font-medium bg-primary text-primary-foreground disabled:opacity-60 disabled:cursor-not-allowed"
      >
        {isLoading ? 'Logging in...' : 'Log In'}
      </button>

      <div className="mt-4 text-center text-sm text-muted-foreground">
        New here?{' '}
        <Link href="/register" className="text-primary font-medium no-underline">
          Create an account
        </Link>
      </div>
    </form>
  );
}
