export interface Cat {
  name: string;
  description: string;
  imageUrl: string;
  price: number;
  tag: string;
}

export const cats: Cat[] = [
  {
    name: "Nebula Neko",
    description: "Softly glows in the dark and purrs in minor keys whenever a comet passes within 3 light‑years…",
    imageUrl: "https://images.unsplash.com/photo-1581840130788-0c20b3d547c0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHxzcGFjZSUyMGdhbGF4eSUyMGNhdCUyMGlsbHVzdHJhdGlvbnxlbnwwfHx8fDE3NjQxMjMwMzV8MA&ixlib=rb-4.1.0&q=80&w=1080",
    price: 48.00,
    tag: "Cozy cosmic"
  },
  {
    name: "Laser Pointer Prodigy",
    description: "Predicts the path of any red dot with 99.9% accuracy and issues tiny smug head tilts on success.",
    imageUrl: "https://images.unsplash.com/photo-1635803823842-1b68832f4f32?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHxjeWJlcnB1bmslMjBuZW9uJTIwY2F0fGVufDB8fHx8MTc2NDEyMzAzNnww&ixlib=rb-4.1.0&q=80&w=1080",
    price: 39.00,
    tag: "Chaotic smart"
  },
  {
    name: "Clockwork Catnapper",
    description: "Takes precisely 23 naps per day and gently ticks like a happy pocket watch when content.",
    imageUrl: "https://images.unsplash.com/photo-1736184722229-1d44ff764062?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHxzdGVhbXB1bmslMjBjYXQlMjBpbGx1c3RyYXRpb258ZW58MHx8fHwxNzY0MTIzMDM3fDA&ixlib=rb-4.1.0&q=80&w=1080",
    price: 42.00,
    tag: "Cozy vintage"
  },
  {
    name: "Whisker Wizard",
    description: "Occasionally rearranges your bookshelf into spell components and curls up inside plot twists.",
    imageUrl: "https://images.unsplash.com/photo-1555870361-44440958e34d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHx3aXphcmQlMjBjYXQlMjBpbGx1c3RyYXRpb258ZW58MHx8fHwxNzY0MTIzMDM4fDA&ixlib=rb-4.1.0&q=80&w=1080",
    price: 51.00,
    tag: "Arcane"
  },
  {
    name: "Loaf Mode Deluxe",
    description: "100% loaf, 0% chaos. Activates maximum comfort fields when placed near laptops or fresh laundry.",
    imageUrl: "https://images.unsplash.com/photo-1708696415689-6bfae2ad4e2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHxsb2FmJTIwY2F0JTIwaWxsdXN0cmF0aW9uJTIwY3V0ZXxlbnwwfHx8fDE3NjQxMjMwNDB8MA&ixlib=rb-4.1.0&q=80&w=1080",
    price: 29.00,
    tag: "Ultra cozy"
  },
  {
    name: "Glitch in the Catrix",
    description: "Sometimes flickers between dimensions and briefly becomes 8‑bit whenever you open a new tab.",
    imageUrl: "https://images.unsplash.com/photo-1702751749015-21c5ab5ba7ae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjYyMDB8MHwxfHNlYXJjaHwxfHxnbGl0Y2glMjBwaXhlbCUyMGFydCUyMGNhdHxlbnwwfHx8fDE3NjQxMjMwNDF8MA&ixlib=rb-4.1.0&q=80&w=1080",
    price: 37.00,
    tag: "Digital chaos"
  }
];

