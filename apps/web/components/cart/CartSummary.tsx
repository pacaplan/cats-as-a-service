import React from 'react';
import Link from 'next/link';
import Button from '../ui/Button';

interface CartSummaryProps {
  itemCount: number;
  subtotal: number;
  showCheckout?: boolean;
  showUniverseFees?: boolean;
  showPromo?: boolean;
}

export default function CartSummary({
  itemCount,
  subtotal,
  showCheckout = true,
  showUniverseFees = false,
  showPromo = false
}: CartSummaryProps) {
  return (
    <aside className="w-[320px] rounded-lg bg-card text-card-foreground p-3 flex flex-col gap-2">
      <div className="text-[14px] font-semibold">Order summary</div>
      <div className="flex justify-between items-center text-[13px] text-muted-foreground">
        <span>Items</span>
        <span>{itemCount} unique cats</span>
      </div>
      <div className="flex justify-between items-center text-[13px] text-muted-foreground">
        <span>Imaginary subtotal</span>
        <span>{subtotal.toFixed(2)} ¢</span>
      </div>
      <div className="flex justify-between items-center text-[13px] text-muted-foreground">
        <span>Shipping</span>
        <span>0.00 ¢ (teleported)</span>
      </div>
      {showUniverseFees && (
        <div className="flex justify-between items-center text-[13px] text-muted-foreground">
          <span>Universe fees</span>
          <span>0.00 ¢</span>
        </div>
      )}
      <div className="my-1 h-[1px] bg-border"></div>
      <div className="flex justify-between items-center text-[14px] font-semibold">
        <span>Total due now</span>
        <span>0.00 ¢</span>
      </div>
      {showCheckout ? (
        <>
          <div className="text-[11px] text-muted-foreground">
            {showUniverseFees
              ? "In a real shop, this card would be doing the trust‑building heavy lifting: totals, fees, and final reassurance."
              : "This is a portfolio experience. No actual payments, billing, or real‑world cats are involved — just UI wiring and product thinking."
            }
          </div>
          <div className="mt-1 flex flex-col gap-[6px]">
            <Link href="/checkout" className="w-full no-underline">
              <Button variant="primary" className="w-full">
                Continue to pretend checkout
              </Button>
            </Link>
            <Link href="/" className="w-full no-underline">
              <Button variant="secondary" className="w-full">
                Keep browsing cats
              </Button>
            </Link>
          </div>
          <div className="mt-[2px] flex flex-col gap-1 text-[12px]">
            <div className="text-[12px] font-medium text-accent-foreground bg-accent rounded-md px-2 py-[6px] cursor-pointer inline-flex items-center justify-center">Clear cart (release all cats)</div>
            <div className="text-[11px] text-muted-foreground">
              {showUniverseFees
                ? "Nothing here is binding. Refresh the page, and the universe forgets this entire transaction."
                : "Need a real cat? Visit adoption resources in the footer instead of expecting this page to spawn one."
              }
            </div>
          </div>
        </>
      ) : (
        <>
          <div className="text-[11px] text-muted-foreground">
            In a real shop, this card would be doing the trust‑building heavy lifting: totals, fees, and final reassurance.
          </div>
          {showPromo && (
            <div className="mt-1 flex flex-col gap-1 text-[12px]">
              <div className="font-medium">Promo / magic word</div>
              <div className="flex gap-[6px]">
                <div className="flex-1 rounded-md bg-input border border-border p-[7px_8px] text-[13px] text-foreground">
                  <span className="text-muted-foreground">Try "MEOWGIC" or leave blank</span>
                </div>
                <Button variant="secondary">Apply</Button>
              </div>
            </div>
          )}
          <div className="mt-1 flex flex-col gap-[6px]">
            <Button variant="primary" className="w-full">
              Skip ahead to order review
            </Button>
            <Link href="/" className="w-full no-underline">
              <Button variant="secondary" className="w-full">
                Keep browsing cats
              </Button>
            </Link>
          </div>
          <div className="mt-[2px] flex flex-col gap-1 text-[12px]">
            <div className="text-[12px] font-medium text-accent-foreground bg-accent rounded-md px-2 py-[6px] cursor-pointer inline-flex items-center justify-center">Clear cart (release all cats)</div>
            <div className="text-[11px] text-muted-foreground">
              Nothing here is binding. Refresh the page, and the universe forgets this entire transaction.
            </div>
          </div>
        </>
      )}
    </aside>
  );
}

