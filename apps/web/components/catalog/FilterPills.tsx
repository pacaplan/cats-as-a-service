import React from 'react';

export default function FilterPills() {
  const filters = ['All vibes', 'Cozy', 'Chaotic', 'Space‑themed'];

  return (
    <div className="flex gap-[6px]">
      {filters.map((filter, index) => (
        <div key={index} className="px-2 py-1 rounded-full bg-muted text-muted-foreground text-[11px] cursor-pointer">
          {filter}
        </div>
      ))}
    </div>
  );
}

