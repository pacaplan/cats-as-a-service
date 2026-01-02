import React from 'react';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import PageHero from '@/components/layout/PageHero';
import LoginForm from '@/components/auth/LoginForm';

export default function LoginPage() {
  return (
    <div className="bg-background text-foreground min-h-screen flex flex-col">
      <div className="max-w-[1120px] mx-auto p-[24px_32px_40px_32px] flex flex-col gap-6">
        <Header />
        <PageHero
          title="Welcome Back, Cat Enthusiast"
          subtitle="Log in to access your saved cats, continue your CatBot conversations, and manage your fictional feline empire."
        />
        <main className="py-6">
          <LoginForm />
        </main>
        <Footer />
      </div>
    </div>
  );
}
