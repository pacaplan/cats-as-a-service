export type PersonalityKey = 'gremlin' | 'regal' | 'cozy' | 'mystic';

export type QuizOption = {
  id: string;
  emoji: string;
  label: string;
  description: string;
  personality: PersonalityKey;
};

export type QuizQuestion = {
  id: string;
  prompt: string;
  detail: string;
  options: QuizOption[];
};

export type PersonalityMatch = {
  id: PersonalityKey;
  name: string;
  description: string;
  asciiArt: string;
  shareText: string;
};

export const quizQuestions: QuizQuestion[] = [
  {
    id: 'energy',
    prompt: 'What energy level do you vibe with?',
    detail: 'Pick the pace that matches your future feline friend.',
    options: [
      {
        id: 'sunbeam',
        emoji: '😴',
        label: 'Sunbeam napper',
        description: 'Prime lounging, occasional stretch, zero drama.',
        personality: 'cozy',
      },
      {
        id: 'zoomies',
        emoji: '🚀',
        label: 'Zoomies icon',
        description: 'Speed runs at 3am, a blur of absolute chaos.',
        personality: 'gremlin',
      },
      {
        id: 'patrol',
        emoji: '🛡️',
        label: 'Hall monitor',
        description: 'Keeps the couch kingdom orderly and pristine.',
        personality: 'regal',
      },
      {
        id: 'float',
        emoji: '✨',
        label: 'Floaty daydreamer',
        description: 'Occasionally levitates? Definitely hums softly.',
        personality: 'mystic',
      },
    ],
  },
  {
    id: 'superpower',
    prompt: 'Choose a signature superpower.',
    detail: 'Every CatBot build gets a quirky specialty.',
    options: [
      {
        id: 'clawconomics',
        emoji: '🧠',
        label: '4D chess',
        description: 'Predicts treat drops and sun angles with precision.',
        personality: 'regal',
      },
      {
        id: 'shadowmeld',
        emoji: '🕶️',
        label: 'Shadowmeld',
        description: "Appears silently at snack o'clock like a rumor.",
        personality: 'mystic',
      },
      {
        id: 'gremlinmode',
        emoji: '⚡',
        label: 'Gremlin mode',
        description: 'Runs heists on your socks, leaves glitter in return.',
        personality: 'gremlin',
      },
      {
        id: 'purrcast',
        emoji: '☕',
        label: 'Comfort casting',
        description: 'Broadcasts cozy vibes and anxiety-canceling purrs.',
        personality: 'cozy',
      },
    ],
  },
  {
    id: 'vacation',
    prompt: 'Dream vacation for your cat?',
    detail: 'Their itinerary says a lot about their personality.',
    options: [
      {
        id: 'spa',
        emoji: '🛁',
        label: 'All-inclusive spa',
        description: 'Warm towels, cucumber eye masks, tailored tuna flights.',
        personality: 'regal',
      },
      {
        id: 'neon',
        emoji: '🌃',
        label: 'Neon alleyways',
        description: 'Night markets, neon signs, cyber fish to chase.',
        personality: 'gremlin',
      },
      {
        id: 'library',
        emoji: '📚',
        label: 'Sunlit library',
        description: 'Stacks of books, quiet nooks, infinite laps.',
        personality: 'cozy',
      },
      {
        id: 'cloud',
        emoji: '☁️',
        label: 'Floating island',
        description: 'Cloud hammocks, crystal waterfalls, gentle echoes.',
        personality: 'mystic',
      },
    ],
  },
  {
    id: 'aesthetic',
    prompt: 'Pick a cat aesthetic.',
    detail: "What's their core vibe?",
    options: [
      {
        id: 'goblin',
        emoji: '🪄',
        label: 'Gremlin glam',
        description: 'Mismatched socks, shiny trinkets, perpetual side-eye.',
        personality: 'gremlin',
      },
      {
        id: 'celestial',
        emoji: '🌙',
        label: 'Celestial oracle',
        description: 'Glowing freckles, crescent whiskers, sings to the moon.',
        personality: 'mystic',
      },
      {
        id: 'hearth',
        emoji: '🧣',
        label: 'Hearth guardian',
        description: 'Cable-knit sweater energy, crumb patrol specialist.',
        personality: 'cozy',
      },
      {
        id: 'royalty',
        emoji: '👑',
        label: 'Palace couture',
        description: 'Velvet cape, collar jewels, impeccable posture.',
        personality: 'regal',
      },
    ],
  },
];

const personalityMatches: Record<PersonalityKey, PersonalityMatch> = {
  gremlin: {
    id: 'gremlin',
    name: 'Chaotic Gremlin',
    description:
      'A spark-sized menace who steals glitter pens, apologizes with loud purrs, and never misses snack time.',
    asciiArt: String.raw`
 /)_/)
( •.•)
/ >🍤`,
    shareText:
      'I matched with the Chaotic Gremlin on CatBot — a mischievous little whirlwind who loves glitter and snacks.',
  },
  regal: {
    id: 'regal',
    name: 'Regal Strategist',
    description:
      'A poised tactician who arranges the couch pillows just so and executes every leap with ceremony.',
    asciiArt: String.raw`
 /\\___/\\
(  •.• )
 > ^ < ︻デ═一`,
    shareText:
      'I matched with the Regal Strategist on CatBot — composed, clever, and deeply in charge of the living room.',
  },
  cozy: {
    id: 'cozy',
    name: 'Cozy Familiar',
    description:
      'A warm blanket come to life — loves sunbeams, brews calm tea vibes, and schedules daily cuddle quotas.',
    asciiArt: String.raw`
 /\\_/\\
( ˘ ˘ )つ━☆
 c(   )`,
    shareText:
      'I matched with the Cozy Familiar on CatBot — pure comfort energy with compulsory cuddle sessions.',
  },
  mystic: {
    id: 'mystic',
    name: 'Mystic Dreamer',
    description:
      'Hums in hex codes, naps on cloud forts, and occasionally predicts rain with a twitch of the whiskers.',
    asciiArt: String.raw`
 /\\_/\\
( o.o )
 > ^ < ✧`,
    shareText:
      'I matched with the Mystic Dreamer on CatBot — floaty, curious, and perpetually shimmering.',
  },
};

const priority: PersonalityKey[] = ['gremlin', 'regal', 'cozy', 'mystic'];

export function calculatePersonality(answers: Record<string, string>): PersonalityMatch {
  const tally: Record<PersonalityKey, number> = {
    gremlin: 0,
    regal: 0,
    cozy: 0,
    mystic: 0,
  };

  quizQuestions.forEach((question) => {
    const chosenId = answers[question.id];
    const option = question.options.find((opt) => opt.id === chosenId);
    if (option) {
      tally[option.personality] += 1;
    }
  });

  const winning = priority.reduce((winner, key) => {
    if (!winner) return key;
    if (tally[key] > tally[winner]) return key;
    if (tally[key] === tally[winner] && priority.indexOf(key) < priority.indexOf(winner)) {
      return key;
    }
    return winner;
  }, priority[0]);

  return personalityMatches[winning];
}

export function getPersonality(id: PersonalityKey) {
  return personalityMatches[id];
}
