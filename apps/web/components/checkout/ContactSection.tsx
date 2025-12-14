import React from 'react';

export default function ContactSection() {
  return (
    <div className="rounded-lg bg-card text-card-foreground p-[14px_14px_12px_14px] flex flex-col gap-[10px]">
      <div className="flex justify-between items-center gap-2">
        <div>
          <div className="text-[14px] font-semibold">Contact details</div>
          <div className="text-[12px] text-muted-foreground">
            We'll send your generated cats and CatBot lore here.
          </div>
        </div>
      </div>
      <div className="flex flex-col gap-2">
        <div className="flex gap-2">
          <div className="flex-1 flex flex-col gap-1 text-[12px]">
            <div className="font-medium">Email for cat delivery</div>
            <div className="rounded-md bg-input border border-border p-[7px_8px] text-[13px] text-foreground flex items-center justify-between gap-2">
              <div className="text-muted-foreground">you@example.com</div>
            </div>
          </div>
        </div>
        <div className="flex gap-2">
          <div className="flex-1 flex flex-col gap-1 text-[12px]">
            <div className="font-medium">Full name</div>
            <div className="rounded-md bg-input border border-border p-[7px_8px] text-[13px] text-foreground flex items-center justify-between gap-2">
              <div className="text-muted-foreground">
                Luna "Chief Cat Herder" Vega
              </div>
            </div>
          </div>
        </div>
        <div className="flex gap-2">
          <div className="flex-1 flex flex-col gap-1 text-[12px]">
            <div className="font-medium">CatBot account</div>
            <div className="rounded-md bg-input border border-border p-[7px_8px] text-[13px] text-foreground flex items-center justify-between gap-2">
              <div className="text-muted-foreground">
                Continue as guest or sign in
              </div>
            </div>
            <div className="mt-[2px] flex gap-[6px] flex-wrap text-[11px]">
              <div className="px-[6px] py-[2px] rounded-full bg-muted text-muted-foreground">Guest checkout</div>
              <div className="px-[6px] py-[2px] rounded-full bg-muted text-muted-foreground">Sign in for saved cats</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}



