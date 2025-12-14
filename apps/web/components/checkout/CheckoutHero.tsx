import React from 'react';
import PageHero from '../layout/PageHero';

export default function CheckoutHero() {
  return (
    <PageHero
      title="Pretend checkout"
      subtitle="Confirm where your fictional felines should be beamed, how we should address you, and which alternate universe is picking up the imaginary tab."
      meta="No real payments are processed here. You're just walking through a standard checkout flow wrapped in cat puns and UX decisions."
      steps={[
        { label: '1. Cart', active: true },
        { label: '2. Details', active: true },
        { label: '3. Review', active: false }
      ]}
    />
  );
}




