import React from 'react';
import Button from '../ui/Button';

export default function SidePanel() {
  return (
    <aside className="w-[260px] rounded-lg bg-card text-card-foreground p-3 flex flex-col gap-3">
      <div className="flex flex-col gap-[6px]">
        <div className="text-[12px] font-semibold">Not sure where to start?</div>
        <div className="rounded-md bg-secondary text-secondary-foreground p-[10px] flex flex-col gap-[6px]">
          <div className="text-[13px] font-semibold">Help me find my ideal cat</div>
          <div className="text-[12px]">
            Answer a few delightfully unnecessary questions and we'll have CatBot sketch out a custom (fictional) feline just for you.
          </div>
          <Button variant="secondary" className="mt-1">
            Start Cat Personality Quiz
          </Button>
        </div>
      </div>
      <div className="flex flex-col gap-[6px]">
        <div className="text-[12px] font-semibold">Guests vs registered humans</div>
        <div className="text-[12px] text-muted-foreground">
          Guests can browse, daydream, and fill a pretend cart. Registered users can also save favorites and unlock the full CatBot builder to craft bespoke imaginary cats.
        </div>
        <div className="text-[11px] text-muted-foreground">
          No emails to real shelters, no surprise deliveries — only vibes and pixels.
        </div>
      </div>
    </aside>
  );
}

