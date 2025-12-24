import React from 'react';
import Link from 'next/link';
import Image from 'next/image';
import Button from '../ui/Button';
import { CatListing } from '@/data/api';

export interface CatCardProps {
  cat: CatListing;
}

// Format tags for display (e.g., ["cozy", "cosmic"] -> "Cozy cosmic")
function formatTags(tags: string[]): string {
  if (tags.length === 0) return '';
  return tags.map((tag, i) => i === 0 ? tag.charAt(0).toUpperCase() + tag.slice(1) : tag).join(' ');
}

export default function CatCard({ cat }: CatCardProps) {
  const { name, description, price, image, tags, slug } = cat;
  const tagDisplay = formatTags(tags);
  
  // Default image if none provided
  const imageUrl = image.url || 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400';
  const imageAlt = image.alt || name;

  return (
    <article className="bg-card text-card-foreground rounded-lg p-2.5 flex flex-col gap-2 shadow-[0_8px_20px_rgba(15,23,42,0.08)]">
      <div className="w-full pt-[70%] rounded-md bg-secondary relative overflow-hidden">
        <Image
          src={imageUrl}
          alt={imageAlt}
          fill
          className="object-cover"
        />
      </div>
      <div className="text-[15px] font-semibold">{name}</div>
      <div className="text-[13px] text-muted-foreground leading-[1.4] max-h-9 overflow-hidden text-ellipsis">{description}</div>
      <div className="flex justify-between items-center mt-1">
        <div className="text-sm font-semibold">{price.formatted}</div>
        <div className="text-[11px] text-muted-foreground">1 of 1{tagDisplay && ` • ${tagDisplay}`}</div>
      </div>
      <div className="flex gap-1.5 mt-1.5">
        <Link href="/cart" className="flex-1 no-underline">
          <Button variant="primary" className="flex-1">
            Add to cart
          </Button>
        </Link>
        <Link href={`/cat/${slug}`} className="text-xs text-accent-foreground bg-accent rounded-md px-2 py-1.5 font-medium flex-none cursor-pointer no-underline">
          View details
        </Link>
      </div>
    </article>
  );
}

