import React from 'react';

export default function PaymentSection() {
  return (
    <div className="rounded-lg bg-card text-card-foreground p-[14px_14px_12px_14px] flex flex-col gap-[10px]">
      <div className="flex justify-between items-center gap-2">
        <div>
          <div className="text-[14px] font-semibold">Payment</div>
          <div className="text-[12px] text-muted-foreground">
            This is the "convince the user" step in a real store. Here, it's just UI theatre.
          </div>
        </div>
      </div>
      <div className="flex flex-col gap-[6px] text-[12px]">
        <div className="flex items-start gap-2 p-[6px_8px] rounded-md bg-input">
          <div className="w-3 h-3 rounded-full border-2 border-primary bg-primary mt-[2px] flex-shrink-0"></div>
          <div className="flex flex-col gap-[2px]">
            <div className="font-medium">Imagination only (0.00 ¢)</div>
            <div className="text-[11px] text-muted-foreground">
              No cards, no wallets, no risk. You'll still see what a payment step would feel like.
            </div>
          </div>
        </div>
        <div className="flex items-start gap-2 p-[6px_8px] rounded-md bg-input">
          <div className="w-3 h-3 rounded-full border-2 border-border mt-[2px] flex-shrink-0"></div>
          <div className="flex flex-col gap-[2px]">
            <div className="font-medium">Mock credit card</div>
            <div className="text-[11px] text-muted-foreground">
              Placeholder for number, expiry, CVV fields — left out here to keep the UI focused.
            </div>
          </div>
        </div>
      </div>
      <div className="text-[11px] text-muted-foreground">
        <span className="font-medium">Reminder:</span> This project never touches real payment data. It just mimics the flow.
      </div>
    </div>
  );
}


