import React from 'react';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import PageHero from '@/components/layout/PageHero';
import RegisterForm from '@/components/auth/RegisterForm';

export default function RegisterPage() {
  return (
    <div className="bg-background text-foreground min-h-screen flex flex-col">
      <div className="max-w-[1120px] mx-auto p-[24px_32px_40px_32px] flex flex-col gap-6">
        <Header />
        <PageHero
          title="Join the Cat-alog Community"
          subtitle="Create an account to save your custom CatBot creations, track your fictional orders, and manage your completely imaginary cat collection."
          meta="All your data is as real as the cats — which is to say, delightfully fictional but perfectly functional for demo purposes."
        />
        <main className="py-6">
          <RegisterForm />
        </main>
        <Footer />
      </div>
    </div>
  );
}
