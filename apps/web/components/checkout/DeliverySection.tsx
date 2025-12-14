import React from 'react';

export default function DeliverySection() {
  return (
    <div className="rounded-lg bg-card text-card-foreground p-[14px_14px_12px_14px] flex flex-col gap-[10px]">
      <div className="flex justify-between items-center gap-2">
        <div>
          <div className="text-[14px] font-semibold">Delivery universe</div>
          <div className="text-[12px] text-muted-foreground">
            Standard fields, whimsical answers. Pick where your cats should exist.
          </div>
        </div>
      </div>
      <div className="flex flex-col gap-2">
        <div className="flex gap-2">
          <div className="flex-1 flex flex-col gap-1 text-[12px]">
            <div className="font-medium">Reality setting</div>
            <div className="rounded-md bg-input border border-border p-[7px_8px] text-[13px] text-foreground flex items-center justify-between gap-2">
              <div className="text-muted-foreground">
                Earth‑adjacent demo universe
              </div>
              <div className="text-[11px] text-muted-foreground">▼</div>
            </div>
          </div>
        </div>
        <div className="flex gap-2">
          <div className="flex-1 flex flex-col gap-1 text-[12px]">
            <div className="font-medium">City</div>
            <div className="rounded-md bg-input border border-border p-[7px_8px] text-[13px] text-foreground flex items-center justify-between gap-2">
              <div className="text-muted-foreground">Starfall City</div>
            </div>
          </div>
          <div className="flex-1 flex flex-col gap-1 text-[12px]">
            <div className="font-medium">Region</div>
            <div className="rounded-md bg-input border border-border p-[7px_8px] text-[13px] text-foreground flex items-center justify-between gap-2">
              <div className="text-muted-foreground">Nebula District</div>
            </div>
          </div>
        </div>
        <div className="flex gap-2">
          <div className="flex-1 flex flex-col gap-1 text-[12px]">
            <div className="font-medium">
              Preferred delivery mode
              <span className="text-[11px] text-muted-foreground"> (imaginary)</span>
            </div>
            <div className="rounded-md bg-input border border-border p-[7px_8px] text-[13px] text-foreground flex items-center justify-between gap-2">
              <div className="text-muted-foreground">
                Quantum doorstep drop‑off
              </div>
            </div>
          </div>
        </div>
        <div className="flex gap-2">
          <div className="flex-1 flex flex-col gap-1 text-[12px]">
            <div className="font-medium">
              Special instructions
              <span className="text-[11px] text-muted-foreground"> (optional)</span>
            </div>
            <div className="rounded-md bg-input border border-border p-[7px_8px] text-[13px] text-foreground flex items-center justify-between gap-2">
              <div className="text-muted-foreground">
                e.g. "Don't ring the doorbell, the dog unionized"
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}



