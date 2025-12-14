'use client';

import React, { useState } from 'react';
import { ShoppingCart } from 'lucide-react';
import MiniCart from './MiniCart';

export default function CartButton() {
  const [isOpen, setIsOpen] = useState(false);
  const cartCount = 2; // Static count for UI-only prototype

  return (
    <div className="relative flex items-center gap-2">
      <button
        className="flex items-center gap-2 px-[10px] py-[6px] rounded-md bg-secondary text-secondary-foreground cursor-pointer border-none font-[inherit]"
        onClick={() => setIsOpen(!isOpen)}
      >
        <div className="w-5 h-5 flex items-center justify-center">
          <ShoppingCart size={18} />
        </div>
        <div className="min-w-[18px] h-[18px] rounded-full bg-accent text-accent-foreground flex items-center justify-center text-[11px] px-1">
          {cartCount}
        </div>
      </button>
      {isOpen && <MiniCart onClose={() => setIsOpen(false)} />}
    </div>
  );
}

