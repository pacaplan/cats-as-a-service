'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import FormInput from './FormInput';
import { useAuth } from '@/contexts/AuthContext';

export default function RegisterForm() {
  const { register } = useAuth();
  const [isLoading, setIsLoading] = useState(false);
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    password_confirmation: '',
    name: '',
  });
  const [errors, setErrors] = useState<{
    email?: string[];
    password?: string[];
    password_confirmation?: string[];
    name?: string[];
    general?: string;
  }>({});

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setErrors({});

    try {
      await register({ user: formData });
      // Success - the AuthContext will handle redirect
    } catch (error: any) {
      if (error.status === 422) {
        // Validation errors from backend
        setErrors(error.errors);
      } else {
        setErrors({ general: 'Registration failed. Please try again.' });
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="max-w-[460px] mx-auto bg-card rounded-lg border border-[rgba(31,27,36,0.08)] p-6">
      {errors.general && (
        <div className="bg-destructive/10 border border-destructive/20 rounded-md p-3 mb-4 text-sm text-destructive">
          {errors.general}
        </div>
      )}

      <FormInput
        label="Email"
        type="email"
        value={formData.email}
        onChange={(value) => setFormData({ ...formData, email: value })}
        error={errors.email}
        placeholder="your@email.com"
        required
        autoComplete="email"
      />

      <FormInput
        label="Name"
        type="text"
        value={formData.name}
        onChange={(value) => setFormData({ ...formData, name: value })}
        error={errors.name}
        placeholder="Your full name"
        required
        autoComplete="name"
      />

      <FormInput
        label="Password"
        type="password"
        value={formData.password}
        onChange={(value) => setFormData({ ...formData, password: value })}
        error={errors.password}
        placeholder="At least 12 characters"
        required
        autoComplete="new-password"
      />

      <FormInput
        label="Confirm Password"
        type="password"
        value={formData.password_confirmation}
        onChange={(value) => setFormData({ ...formData, password_confirmation: value })}
        error={errors.password_confirmation}
        placeholder="Re-type your password"
        required
        autoComplete="new-password"
      />

      <button
        type="submit"
        disabled={isLoading}
        className="w-full mt-2 rounded-md px-2.5 py-2 text-[13px] font-medium bg-primary text-primary-foreground disabled:opacity-60 disabled:cursor-not-allowed"
      >
        {isLoading ? 'Creating account...' : 'Create Account'}
      </button>

      <div className="mt-4 text-center text-sm text-muted-foreground">
        Already have an account?{' '}
        <Link href="/login" className="text-primary font-medium no-underline">
          Log in
        </Link>
      </div>
    </form>
  );
}
