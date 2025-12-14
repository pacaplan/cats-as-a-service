import React from 'react';
import Image from 'next/image';
import Button from '../ui/Button';
import { Cat } from '@/data/cats';

interface CartItemProps {
  cat: Cat;
}

export default function CartItem({ cat }: CartItemProps) {
  return (
    <article className="rounded-lg bg-card text-card-foreground p-[10px_12px] flex gap-[10px] items-start">
      <div className="w-16 h-16 rounded-md bg-secondary overflow-hidden flex-shrink-0 relative">
        <Image
          src={cat.imageUrl}
          alt={cat.name}
          fill
          className="object-cover"
        />
      </div>
      <div className="flex-1 flex flex-col gap-1">
        <div className="flex justify-between items-start gap-2">
          <div className="text-[14px] font-semibold">{cat.name}</div>
          <div className="text-[14px] font-semibold">{cat.price.toFixed(2)} ¢</div>
        </div>
        <div className="flex flex-wrap gap-2 text-[12px] text-muted-foreground">
          <span>Rarity: 1 of 1</span>
          <span>Vibe: {cat.tag}</span>
          <div className="px-[6px] py-[2px] rounded-full bg-muted text-muted-foreground text-[11px]">Pre‑made Cat‑alog pick</div>
        </div>
        <div className="mt-1 flex justify-between items-center gap-2 text-[12px]">
          <div className="text-[11px] text-muted-foreground">
            Quantity is locked to 1 — this little stargazer is non‑duplicable.
          </div>
          <div className="flex gap-2">
            <Button variant="ghost">Remove</Button>
            <Button variant="secondary">Move to wishlist</Button>
          </div>
        </div>
      </div>
    </article>
  );
}




