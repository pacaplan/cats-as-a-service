import React from 'react';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import Hero from '@/components/catalog/Hero';
import CatGrid from '@/components/catalog/CatGrid';
import FilterPills from '@/components/catalog/FilterPills';
import SidePanel from '@/components/catalog/SidePanel';
import { fetchCatalog, CatListing } from '@/data/api';
import { cats as fallbackCats } from '@/data/cats';

// Transform fallback cats to match API format
function transformFallbackCats(): CatListing[] {
  return fallbackCats.map((cat, index) => ({
    id: `fallback-${index}`,
    name: cat.name,
    slug: cat.name.toLowerCase().replace(/\s+/g, '-'),
    description: cat.description,
    price: {
      cents: Math.round(cat.price * 100),
      currency: 'USD',
      formatted: `$${cat.price.toFixed(2)}`,
    },
    image: {
      url: cat.imageUrl,
      alt: cat.name,
    },
    tags: cat.tag.toLowerCase().split(' '),
  }));
}

async function getCatalog(): Promise<{ cats: CatListing[]; count: number; isFromApi: boolean }> {
  try {
    const response = await fetchCatalog();
    return { cats: response.listings, count: response.count, isFromApi: true };
  } catch (error) {
    // Fallback to static data if API is unavailable
    console.error('Failed to fetch catalog from API, using fallback data:', error);
    const fallback = transformFallbackCats();
    return { cats: fallback, count: fallback.length, isFromApi: false };
  }
}

export default async function Home() {
  const { cats, count } = await getCatalog();

  return (
    <div className="bg-background text-foreground min-h-screen flex flex-col">
      <div className="max-w-[1120px] mx-auto p-[24px_32px_40px_32px] flex flex-col gap-6">
        <Header />
        <Hero />
        <main className="flex gap-5 items-start">
          <div className="flex-1 flex flex-col gap-4">
            <div className="flex justify-between items-center text-[13px] font-semibold">
              <span>Featured pre‑made cats</span>
              <span>Showing {count} whimsical prototypes</span>
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
