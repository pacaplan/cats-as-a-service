import React from 'react';
import Link from 'next/link';

export default function FAQAside() {
  return (
    <aside className="w-[320px] rounded-lg bg-card text-card-foreground p-3 flex flex-col gap-[10px]">
      <div className="flex flex-col gap-1">
        <div className="text-[12px] font-semibold">About the human behind the cats</div>
        <div className="text-[12px] text-muted-foreground leading-[1.5]">
          Hi, I'm the person who thought, "What if my portfolio pretended to be a whimsical cat store?" I build products that balance polish, clarity, and a slightly alarming number of puns.
        </div>
        <div className="flex flex-wrap gap-[6px] mt-1">
          <div className="px-2 py-1 rounded-full bg-muted text-muted-foreground text-[11px]">Full‑stack / product‑minded</div>
          <div className="px-2 py-1 rounded-full bg-muted text-muted-foreground text-[11px]">Loves thoughtful UX</div>
          <div className="px-2 py-1 rounded-full bg-muted text-muted-foreground text-[11px]">Comfortable with AI tooling</div>
          <div className="px-2 py-1 rounded-full bg-muted text-muted-foreground text-[11px]">Enjoys silly side projects</div>
        </div>
      </div>
      <div className="flex flex-col gap-1">
        <div className="text-[12px] font-semibold">
          If you're a recruiter or hiring manager
        </div>
        <div className="text-[12px] text-muted-foreground leading-[1.5]">
          You're very much in the target audience of this page. The Cat‑alog, CatBot flow, and mini‑cart are here to give you a quick read on how I think about systems, not just one‑off components.
        </div>
        <div className="mt-[6px] flex flex-col gap-1 text-[12px]">
          <div className="text-[12px] font-medium text-accent-foreground bg-accent rounded-md px-2 py-[6px] cursor-pointer inline-flex items-center gap-1 no-underline mb-1">
            View the code on github.com/pacaplan/rampart
          </div>
          <div className="text-[11px] text-muted-foreground mt-1">
            Want to talk? You can open an issue, reach out via the contact info in the repo, or just mention the "imaginary cat store" in your message so I know how you found me.
          </div>
        </div>
      </div>
      <div className="flex flex-col gap-1">
        <div className="text-[12px] font-semibold">So what should I click next?</div>
        <div className="text-[12px] text-muted-foreground leading-[1.5]">
          If you're a casual visitor, head back to the Cat‑alog to browse pre‑made cats. If you're evaluating this as a portfolio, explore the CatBot tab to see the custom builder flow in action.
        </div>
        <div className="mt-[6px] flex flex-col gap-1 text-[12px]">
          <Link href="/" className="text-[12px] font-medium text-accent-foreground bg-accent rounded-md px-2 py-[6px] cursor-pointer inline-flex items-center gap-1 no-underline mb-1">
            Return to Cat‑alog
          </Link>
          <Link href="/catbot" className="text-[12px] font-medium text-accent-foreground bg-accent rounded-md px-2 py-[6px] cursor-pointer inline-flex items-center gap-1 no-underline mb-1">
            Jump to CatBot flow
          </Link>
        </div>
      </div>
    </aside>
  );
}



