import React from 'react';

interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'ghost';
  className?: string;
  onClick?: () => void;
  disabled?: boolean;
}

export default function Button({
  children,
  variant = 'primary',
  className = '',
  onClick,
  disabled = false
}: ButtonProps) {
  const baseClass = 'rounded-md px-2.5 py-2 text-[13px] font-medium flex items-center justify-center cursor-pointer border-none';

  const variantClasses = {
    primary: 'bg-primary text-primary-foreground',
    secondary: 'bg-secondary text-secondary-foreground',
    ghost: 'bg-transparent text-foreground'
  };

  const combinedClass = `${baseClass} ${variantClasses[variant]} ${className} disabled:opacity-60 disabled:cursor-not-allowed`.trim();

  return (
    <button
      className={combinedClass}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
}

