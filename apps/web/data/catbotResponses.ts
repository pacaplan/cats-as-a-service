import { PersonalityMatch } from './quiz';

export type CatAction = {
  text: string;
  tone: 'purr' | 'dramatic' | 'sparkle';
};

export const catbotHeaderArt = String.raw`
 /\\_/\\
( o.o )  — CatBot online
 > ^ <`;

export const mockNameSuggestions = ['Pixel Pounce', 'Nimbus Noodle', 'Captain Whisk'];

export const mockCatDescriptions = [
  'A soft-focus feline who smells faintly of warm pancakes and adventure.',
  'A neon alley cat with reflective whiskers and a tactical hoodie.',
  'A regal strategist who insists the throw pillows align with the stars.',
  'A cozy hearth guardian who schedules cuddle appointments.',
  'A mystic dreamer with constellation freckles and a quiet hum.',
];

const personalityDescriptions: Record<string, string> = {
  gremlin: 'A neon alley cat with reflective whiskers and a tactical hoodie.',
  regal: 'A regal strategist who insists the throw pillows align with the stars.',
  cozy: 'A cozy hearth guardian who schedules cuddle appointments.',
  mystic: 'A mystic dreamer with constellation freckles and a quiet hum.',
};

export const mockBotResponses = [
  'Noted! I am aligning whiskers with your vibe.',
  'Adding extra toe beans to the blueprint — because we can.',
  'Calibrating purr engines and sparkle output.',
  'Drafting a 3am zoomies escape route.',
  'Okay! I will make sure the ears are especially boopable.',
];

export const catActions: CatAction[] = [
  { text: '*Purrs excitedly and knocks over a pencil*', tone: 'purr' },
  { text: '*Tail swish intensifies as ideas form*', tone: 'dramatic' },
  { text: '*Sprinkles digital catnip sparkles everywhere*', tone: 'sparkle' },
];

export const imageProgress = [
  { progress: 18, text: 'Sketching the perfect whisker arcs...' },
  { progress: 42, text: 'Adding physics-defying ear fluff...' },
  { progress: 73, text: 'Airbrushing cinematic backlighting...' },
  { progress: 100, text: 'Finalizing the purr engine calibration!' },
];

export function buildWelcomeMessage(personality?: PersonalityMatch) {
  if (!personality) {
    return 'Welcome to CatBot! I can conjure a custom feline — tell me the vibe or pick from these name sparks.';
  }
  return `Welcome back, ${personality.name} fan! I can turn that energy into a bespoke cat. Want me to start sculpting?`;
}

export function pickMockResponse(index: number) {
  return mockBotResponses[index % mockBotResponses.length];
}

export function pickCatDescription(personality?: PersonalityMatch) {
  if (!personality) {
    return mockCatDescriptions[0];
  }
  return personalityDescriptions[personality.id] ?? mockCatDescriptions[0];
}

export function nextCatAction(index: number): CatAction {
  return catActions[index % catActions.length];
}
