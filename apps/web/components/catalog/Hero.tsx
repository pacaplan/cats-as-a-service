import React from 'react';
import Link from 'next/link';
import Button from '../ui/Button';

export default function Hero() {
  return (
    <section className="mt-2 p-5 rounded-lg bg-secondary text-secondary-foreground flex flex-col gap-3">
      <div className="flex flex-col gap-2">
        <div className="text-[32px] font-bold">Cat‑alog</div>
        <div className="text-[14px] max-w-[520px]">
          Browse a completely fictional collection of pre‑made, AI‑imagined cats. Window‑shop, daydream, and discover the CatBot that helps you design your perfect (still imaginary) companion.
        </div>
      </div>
      <div className="flex flex-wrap gap-2 mt-1">
        <Button variant="primary">Browse Pre‑Made Cats</Button>
        <Link href="/catbot">
          <Button variant="secondary">
            Build Your Own with CatBot
          </Button>
        </Link>
      </div>
      <div className="text-[11px] text-muted-foreground">
        Building custom cats requires an account. Guests can preview the CatBot flow from the CatBot tab.
      </div>
      <div className="mt-1 text-[11px] text-muted-foreground">
        This is not a real store. No actual cats are sold, shipped, cloned, or turned into quantum particles here.
      </div>
    </section>
  );
}

