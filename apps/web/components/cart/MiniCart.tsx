'use client';

import React from 'react';
import Link from 'next/link';
import Image from 'next/image';
import Button from '../ui/Button';

interface MiniCartProps {
  onClose: () => void;
}

export default function MiniCart({ onClose }: MiniCartProps) {
  // Static cart data for UI-only prototype
  const cartItems = [
    {
      name: "Nebula Neko",
      imageUrl: "https://images.unsplash.com/photo-1612177037142-cd92f4e754e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHxjYXJ0b29uJTIwZ2FsYXh5JTIwY2F0fGVufDB8fHx8MTc2NDEyMzAzMHww&ixlib=rb-4.1.0&q=80&w=1080",
      price: 48.00
    },
    {
      name: "Laser Pointer Prodigy",
      imageUrl: "https://images.unsplash.com/photo-1615639164213-aab04da93c7c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHxjeWJlcnB1bmslMjBjYXQlMjBpbGx1c3RyYXRpb258ZW58MHx8fHwxNzY0MTIzMDMxfDA&ixlib=rb-4.1.0&q=80&w=1080",
      price: 39.00
    }
  ];

  const subtotal = cartItems.reduce((sum, item) => sum + item.price, 0);

  return (
    <div className="absolute right-0 top-9 w-[260px] bg-card text-card-foreground rounded-lg p-3 flex flex-col gap-2 shadow-[0_10px_30px_rgba(15,23,42,0.18)] z-10">
      <div className="text-[13px] font-semibold flex justify-between items-center">
        <span>Mini cart</span>
        <span>{cartItems.length} unique cats</span>
      </div>
      <div className="flex flex-col gap-[6px]">
        {cartItems.map((item, index) => (
          <div key={index} className="flex items-center gap-2 text-[12px]">
            <div className="w-8 h-8 rounded-md bg-secondary overflow-hidden flex-shrink-0">
              <Image
                src={item.imageUrl}
                alt={item.name}
                width={32}
                height={32}
                className="w-full h-full object-cover"
              />
            </div>
            <div className="flex-1 flex flex-col gap-[2px]">
              <div className="font-medium whitespace-nowrap overflow-hidden text-ellipsis">{item.name}</div>
              <div className="flex justify-between items-center text-[11px] text-muted-foreground">
                <span>1 of 1</span>
                <span>{item.price.toFixed(2)} ¢</span>
              </div>
            </div>
          </div>
        ))}
      </div>
      <div className="mt-1 pt-[6px] border-t border-border flex justify-between text-[13px] font-medium">
        <span>Subtotal</span>
        <span>{subtotal.toFixed(2)} ¢</span>
      </div>
      <div className="flex gap-2 mt-1">
        <Link href="/cart" onClick={onClose} className="flex-1 no-underline">
          <Button variant="secondary" className="flex-1">
            View cart
          </Button>
        </Link>
        <Link href="/checkout" onClick={onClose} className="flex-1 no-underline">
          <Button variant="primary">
            Checkout
          </Button>
        </Link>
      </div>
      <div className="mt-[2px] text-[11px] text-muted-foreground">
        Quantities are always 1 — every cat is one‑of‑a‑kind.
      </div>
    </div>
  );
}

