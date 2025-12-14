import React from 'react';
import Link from 'next/link';
import Image from 'next/image';
import Button from '../ui/Button';

export interface CatCardProps {
  name: string;
  description: string;
  imageUrl: string;
  price: number;
  tag: string;
}

export default function CatCard({ name, description, imageUrl, price, tag }: CatCardProps) {
  return (
    <article className="bg-card text-card-foreground rounded-lg p-2.5 flex flex-col gap-2 shadow-[0_8px_20px_rgba(15,23,42,0.08)]">
      <div className="w-full pt-[70%] rounded-md bg-secondary relative overflow-hidden">
        <Image
          src={imageUrl}
          alt={name}
          fill
          className="object-cover"
        />
      </div>
      <div className="text-[15px] font-semibold">{name}</div>
      <div className="text-[13px] text-muted-foreground leading-[1.4] max-h-9 overflow-hidden text-ellipsis">{description}</div>
      <div className="flex justify-between items-center mt-1">
        <div className="text-sm font-semibold">{price.toFixed(2)} ¢</div>
        <div className="text-[11px] text-muted-foreground">1 of 1 • {tag}</div>
      </div>
      <div className="flex gap-1.5 mt-1.5">
        <Link href="/cart" className="flex-1 no-underline">
          <Button variant="primary" className="flex-1">
            Add to cart
          </Button>
        </Link>
        <div className="text-xs text-accent-foreground bg-accent rounded-md px-2 py-1.5 font-medium flex-none cursor-pointer">View details</div>
      </div>
    </article>
  );
}

