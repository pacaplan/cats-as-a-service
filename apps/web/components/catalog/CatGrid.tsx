import React from 'react';
import CatCard, { CatCardProps } from './CatCard';

interface CatGridProps {
  cats: CatCardProps[];
}

export default function CatGrid({ cats }: CatGridProps) {
  return (
    <div className="flex flex-col gap-[10px]">
      <div className="grid grid-cols-3 gap-3">
        {cats.map((cat, index) => (
          <CatCard key={index} {...cat} />
        ))}
      </div>
      <div className="flex justify-between items-center p-[10px_12px] rounded-md bg-muted text-muted-foreground text-[12px]">
        <span className="max-w-[420px]">
          If you don't see your dream cat here, it just means it hasn't been imagined yet. That's what CatBot is for.
        </span>
        <div className="text-[12px] font-medium text-foreground cursor-pointer">
          Take the Cat Personality Quiz →
        </div>
      </div>
    </div>
  );
}

