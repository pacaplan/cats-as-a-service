import React from 'react';
import Link from 'next/link';
import Image from 'next/image';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import Button from '@/components/ui/Button';
import { fetchCatListing, CatListing } from '@/data/api';
import { notFound } from 'next/navigation';

interface CatDetailPageProps {
  params: Promise<{ slug: string }>;
}

async function getCatListing(slug: string): Promise<CatListing | null> {
  try {
    return await fetchCatListing(slug);
  } catch (error) {
    console.error('Failed to fetch cat listing:', error);
    return null;
  }
}

// Format tags for display
function formatTags(tags: string[]): string {
  if (tags.length === 0) return '';
  return tags.map((tag, i) => i === 0 ? tag.charAt(0).toUpperCase() + tag.slice(1) : tag).join(' ');
}

export default async function CatDetailPage({ params }: CatDetailPageProps) {
  const { slug } = await params;
  const cat = await getCatListing(slug);

  if (!cat) {
    notFound();
  }

  const imageUrl = cat.image.url || 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800';
  const imageAlt = cat.image.alt || cat.name;
  const tagDisplay = formatTags(cat.tags);

  return (
    <div className="bg-background text-foreground min-h-screen flex flex-col">
      <div className="max-w-[1120px] mx-auto p-[24px_32px_40px_32px] flex flex-col gap-6">
        <Header />
        
        <main className="flex gap-8">
          {/* Image Section */}
          <div className="flex-1">
            <div className="relative w-full aspect-square rounded-xl overflow-hidden bg-secondary">
              <Image
                src={imageUrl}
                alt={imageAlt}
                fill
                className="object-cover"
                priority
              />
            </div>
          </div>

          {/* Details Section */}
          <div className="flex-1 flex flex-col gap-6">
            <div>
              <Link 
                href="/" 
                className="text-sm text-muted-foreground hover:text-foreground transition-colors no-underline"
              >
                ← Back to catalog
              </Link>
            </div>

            <div className="flex flex-col gap-2">
              <h1 className="text-3xl font-bold">{cat.name}</h1>
              {tagDisplay && (
                <div className="text-sm text-muted-foreground">{tagDisplay}</div>
              )}
            </div>

            <div className="text-2xl font-bold text-primary">
              {cat.price.formatted}
            </div>

            <div className="flex flex-col gap-2">
              <h2 className="text-lg font-semibold">About this cat</h2>
              <p className="text-muted-foreground leading-relaxed">
                {cat.description}
              </p>
            </div>

            <div className="flex flex-col gap-3 mt-4">
              <Link href="/cart" className="no-underline">
                <Button variant="primary" className="w-full py-3 text-base">
                  Add to cart
                </Button>
              </Link>
              <div className="text-center text-sm text-muted-foreground">
                1 of 1 • Unique digital companion
              </div>
            </div>

            <div className="mt-6 p-4 rounded-lg bg-muted">
              <h3 className="text-sm font-semibold mb-2">What you get</h3>
              <ul className="text-sm text-muted-foreground space-y-1">
                <li>✨ Unique AI-generated cat personality</li>
                <li>🎨 High-resolution digital artwork</li>
                <li>📜 Certificate of authenticity</li>
                <li>💝 Lifetime companion status</li>
              </ul>
            </div>
          </div>
        </main>

        <Footer />
      </div>
    </div>
  );
}

