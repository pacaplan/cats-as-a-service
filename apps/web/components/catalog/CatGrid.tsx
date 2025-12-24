import React from 'react';
import Link from 'next/link';
import CatCard from './CatCard';
import { CatListing } from '@/data/api';

interface CatGridProps {
  cats: CatListing[];
}

export default function CatGrid({ cats }: CatGridProps) {
  return (
    <div className="flex flex-col gap-[10px]">
      <div className="grid grid-cols-3 gap-3">
        {cats.map((cat) => (
          <CatCard key={cat.id} cat={cat} />
        ))}
      </div>
      <div className="flex justify-between items-center p-[10px_12px] rounded-md bg-muted text-muted-foreground text-[12px]">
        <span className="max-w-[420px]">
          If you don&apos;t see your dream cat here, it just means it hasn&apos;t been imagined yet. That&apos;s what CatBot is for.
        </span>
        <Link href="/catbot" className="text-[12px] font-medium text-foreground cursor-pointer no-underline hover:underline">
          Take the Cat Personality Quiz →
        </Link>
      </div>
    </div>
  );
}

