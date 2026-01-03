-- Seed data for cat_listings table
-- This populates the catalog with initial published cats

INSERT INTO cat_content.cat_listings (name, slug, description, price_cents, currency, visibility, image_url, image_alt, tags)
VALUES 
  (
    'Nebula Neko',
    'nebula-neko',
    'Softly glows in the dark and purrs in minor keys whenever a comet passes within 3 light-years. Prefers quiet evenings and existential conversations about the void.',
    4800,
    'USD',
    'published',
    'https://images.unsplash.com/photo-1581840130788-0c20b3d547c0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHxzcGFjZSUyMGdhbGF4eSUyMGNhdCUyMGlsbHVzdHJhdGlvbnxlbnwwfHx8fDE3NjQxMjMwMzV8MA&ixlib=rb-4.1.0&q=80&w=1080',
    'Nebula Neko illustration',
    ARRAY['cozy', 'cosmic']
  ),
  (
    'Laser Pointer Prodigy',
    'laser-pointer-prodigy',
    'Predicts the path of any red dot with 99.9% accuracy and issues tiny smug head tilts on success. Has been known to outsmart laser-wielding humans consistently.',
    3900,
    'USD',
    'published',
    'https://images.unsplash.com/photo-1635803823842-1b68832f4f32?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHxjeWJlcnB1bmslMjBuZW9uJTIwY2F0fGVufDB8fHx8MTc2NDEyMzAzNnww&ixlib=rb-4.1.0&q=80&w=1080',
    'Laser Pointer Prodigy illustration',
    ARRAY['chaotic', 'smart']
  ),
  (
    'Clockwork Catnapper',
    'clockwork-catnapper',
    'Takes precisely 23 naps per day and gently ticks like a happy pocket watch when content. Synchronized with the rotation of the Earth for optimal rest cycles.',
    4200,
    'USD',
    'published',
    'https://images.unsplash.com/photo-1736184722229-1d44ff764062?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHxzdGVhbXB1bmslMjBjYXQlMjBpbGx1c3RyYXRpb258ZW58MHx8fHwxNzY0MTIzMDM3fDA&ixlib=rb-4.1.0&q=80&w=1080',
    'Clockwork Catnapper illustration',
    ARRAY['cozy', 'vintage']
  ),
  (
    'Whisker Wizard',
    'whisker-wizard',
    'Occasionally rearranges your bookshelf into spell components and curls up inside plot twists. Known to cast minor enchantments that make your coffee taste slightly better.',
    5100,
    'USD',
    'published',
    'https://images.unsplash.com/photo-1555870361-44440958e34d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHx3aXphcmQlMjBjYXQlMjBpbGx1c3RyYXRpb258ZW58MHx8fHwxNzY0MTIzMDM4fDA&ixlib=rb-4.1.0&q=80&w=1080',
    'Whisker Wizard illustration',
    ARRAY['arcane', 'mysterious']
  ),
  (
    'Loaf Mode Deluxe',
    'loaf-mode-deluxe',
    '100% loaf, 0% chaos. Activates maximum comfort fields when placed near laptops or fresh laundry. The ultimate companion for cozy afternoons.',
    2900,
    'USD',
    'published',
    'https://images.unsplash.com/photo-1708696415689-6bfae2ad4e2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHxsb2FmJTIwY2F0JTIwaWxsdXN0cmF0aW9uJTIwY3V0ZXxlbnwwfHx8fDE3NjQxMjMwNDB8MA&ixlib=rb-4.1.0&q=80&w=1080',
    'Loaf Mode Deluxe illustration',
    ARRAY['ultra', 'cozy']
  ),
  (
    'Glitch in the Catrix',
    'glitch-in-the-catrix',
    'Sometimes flickers between dimensions and briefly becomes 8-bit whenever you open a new tab. May occasionally phase through solid objects when startled.',
    3700,
    'USD',
    'published',
    'https://images.unsplash.com/photo-1702751749015-21c5ab5ba7ae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHxnbGl0Y2glMjBwaXhlbCUyMGFydCUyMGNhdHxlbnwwfHx8fDE3NjQxMjMwNDF8MA&ixlib=rb-4.1.0&q=80&w=1080',
    'Glitch in the Catrix illustration',
    ARRAY['digital', 'chaos']
  )
ON CONFLICT (slug) DO NOTHING;



