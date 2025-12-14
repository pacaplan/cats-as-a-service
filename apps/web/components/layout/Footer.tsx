import React from 'react';
import Link from 'next/link';

export default function Footer() {
  return (
    <footer className="mt-5 pt-4 border-t border-border flex justify-between items-center text-xs gap-4">
      <div className="flex gap-3 flex-wrap">
        <Link href="/faq" className="text-muted-foreground cursor-pointer no-underline">FAQ</Link>
        <div className="text-muted-foreground cursor-pointer">Is this real?</div>
        <div className="text-muted-foreground cursor-pointer">View on GitHub</div>
        <div className="text-muted-foreground cursor-pointer">Adoption resources</div>
      </div>
      <div className="text-muted-foreground">
        For actual cats, please visit local shelters and rescues. This Cat‑alog is 100% imaginary and 0% transactional.
      </div>
    </footer>
  );
}

