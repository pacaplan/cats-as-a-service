'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import CartButton from '../cart/CartButton';

export default function Header() {
  const pathname = usePathname();

  const isActive = (path: string) => {
    if (path === '/') {
      return pathname === '/';
    }
    return pathname?.startsWith(path);
  };

  return (
    <header className="flex items-center justify-between gap-4">
      <Link href="/" className="flex items-center gap-2 text-lg font-semibold no-underline">
        <div className="w-7 h-7 rounded-lg bg-secondary flex items-center justify-center text-lg">🐾</div>
        <div>Custom Cat Co.</div>
      </Link>
      <nav className="flex gap-4 text-sm font-medium">
        <Link
          href="/"
          className={`px-3 py-2 rounded-md cursor-pointer no-underline inline-block ${
            isActive('/') ? 'bg-secondary text-secondary-foreground' : 'text-muted-foreground'
          }`}
        >
          Cat‑alog
        </Link>
        <Link
          href="/catbot"
          className={`px-3 py-2 rounded-md cursor-pointer no-underline inline-block ${
            isActive('/catbot') ? 'bg-secondary text-secondary-foreground' : 'text-muted-foreground'
          }`}
        >
          CatBot
        </Link>
        <Link
          href="/faq"
          className={`px-3 py-2 rounded-md cursor-pointer no-underline inline-block ${
            isActive('/faq') ? 'bg-secondary text-secondary-foreground' : 'text-muted-foreground'
          }`}
        >
          FAQ
        </Link>
      </nav>
      <div className="flex items-center gap-4 text-sm">
        <div className="text-foreground font-medium cursor-pointer">Log in / Sign up</div>
        <CartButton />
      </div>
    </header>
  );
}

