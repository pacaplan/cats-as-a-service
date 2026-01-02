'use client';

import React from 'react';

interface FormInputProps {
  label: string;
  type: string;
  value: string;
  onChange: (value: string) => void;
  error?: string[];
  placeholder?: string;
  required?: boolean;
  autoComplete?: string;
}

export default function FormInput({
  label,
  type,
  value,
  onChange,
  error,
  placeholder,
  required = false,
  autoComplete,
}: FormInputProps) {
  const hasError = error && error.length > 0;

  return (
    <div className="mb-4">
      <label className="block text-sm font-medium mb-1.5 text-foreground">
        {label}
        {required && <span className="text-destructive ml-1">*</span>}
      </label>
      <input
        type={type}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        autoComplete={autoComplete}
        className={`w-full rounded-md border px-3 py-2.5 text-sm outline-none transition-colors ${
          hasError
            ? 'border-destructive focus:border-destructive focus:ring-1 focus:ring-destructive'
            : 'border-[rgba(31,27,36,0.1)] bg-input focus:border-primary focus:ring-1 focus:ring-primary'
        }`}
      />
      {hasError && (
        <div className="mt-1.5 text-xs text-destructive">
          {error.map((err, index) => (
            <div key={index}>{err}</div>
          ))}
        </div>
      )}
    </div>
  );
}
