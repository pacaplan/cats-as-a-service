import React from 'react';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import Hero from '@/components/catalog/Hero';
import CatGrid from '@/components/catalog/CatGrid';
import FilterPills from '@/components/catalog/FilterPills';
import SidePanel from '@/components/catalog/SidePanel';
import { cats } from '@/data/cats';

export default function Home() {
  return (
    <div className="bg-background text-foreground min-h-screen flex flex-col">
      <div className="max-w-[1120px] mx-auto p-[24px_32px_40px_32px] flex flex-col gap-6">
        <Header />
        <Hero />
        <main className="flex gap-5 items-start">
          <div className="flex-1 flex flex-col gap-4">
            <div className="flex justify-between items-center text-[13px] font-semibold">
              <span>Featured pre‑made cats</span>
              <span>Showing {cats.length} whimsical prototypes</span>
            </div>
            <FilterPills />
            <CatGrid cats={cats} />
          </div>
          <SidePanel />
        </main>
        <Footer />
      </div>
    </div>
  );
}

