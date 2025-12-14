import React from 'react';
import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import CheckoutHero from '@/components/checkout/CheckoutHero';
import ContactSection from '@/components/checkout/ContactSection';
import DeliverySection from '@/components/checkout/DeliverySection';
import PaymentSection from '@/components/checkout/PaymentSection';
import CartSummary from '@/components/cart/CartSummary';
import Button from '@/components/ui/Button';
import { cats } from '@/data/cats';

export default function CheckoutPage() {
  // Use first 2 cats as static cart contents
  const cartCats = cats.slice(0, 2);
  const subtotal = cartCats.reduce((sum, cat) => sum + cat.price, 0);

  return (
    <div className="bg-background text-foreground min-h-screen flex flex-col">
      <div className="max-w-[1120px] mx-auto p-[24px_32px_40px_32px] flex flex-col gap-6">
        <Header />
        <CheckoutHero />
        <main className="flex gap-5 items-start">
          <section className="flex-1 flex flex-col gap-4">
            <ContactSection />
            <DeliverySection />
            <PaymentSection />
            <div className="flex justify-between items-center mt-1 gap-3">
              <div className="text-[12px] text-muted-foreground flex gap-2 items-center">
                <Link href="/cart">
                  <Button variant="ghost">← Back to cart</Button>
                </Link>
                <div className="text-[11px] text-muted-foreground">
                  You can still remove or swap cats before "placing" your pretend order.
                </div>
              </div>
              <div className="flex gap-2 items-center">
                <Button variant="secondary">Save checkout state</Button>
                <Button variant="primary">Review & place pretend order</Button>
              </div>
            </div>
          </section>
          <CartSummary
            itemCount={cartCats.length}
            subtotal={subtotal}
            showCheckout={false}
            showUniverseFees={true}
            showPromo={true}
          />
        </main>
        <Footer />
      </div>
    </div>
  );
}



