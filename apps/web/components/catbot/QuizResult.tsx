import React from 'react';
import { PersonalityMatch } from '@/data/quiz';

type Props = {
  personalityMatch: PersonalityMatch;
  onCreateCat: () => void;
  onRetake: () => void;
  onShare: () => void;
};

export default function QuizResult({ personalityMatch, onCreateCat, onRetake, onShare }: Props) {
  return (
    <div className="bg-gradient-to-br from-[#fff3e4] to-[#f0eaff] rounded-[18px] border border-[rgba(31,27,36,0.08)] p-6 flex flex-col gap-4 items-center text-center shadow-[0_18px_36px_rgba(31,27,36,0.08)]">
      <div className="self-center bg-white text-[#5b436d] rounded-full px-3 py-[6px] font-extrabold tracking-[0.02em] border border-dashed border-[rgba(31,27,36,0.12)]">Your match</div>
      <pre className="bg-white rounded-lg p-3 font-mono text-[16px] leading-[1.4] border border-[rgba(31,27,36,0.06)]">{personalityMatch.asciiArt}</pre>
      <h1 className="text-[28px] my-2">{personalityMatch.name}</h1>
      <p className="text-muted-foreground leading-[1.6] max-w-[600px] text-[16px]">{personalityMatch.description}</p>
      <div className="flex gap-[10px] flex-wrap justify-center mt-2">
        <button className="px-4 py-3 rounded-xl font-extrabold border-none cursor-pointer bg-primary text-primary-foreground shadow-[0_12px_24px_rgba(255,140,66,0.25)] hover:translate-y-[-1px]" onClick={onCreateCat}>
          Create This Cat with CatBot
        </button>
        <button className="px-4 py-3 rounded-xl font-extrabold border border-[rgba(31,27,36,0.1)] cursor-pointer bg-white text-foreground hover:translate-y-[-1px]" onClick={onRetake}>
          Retake Quiz
        </button>
        <button className="px-4 py-3 rounded-xl font-extrabold border-none cursor-pointer bg-secondary text-secondary-foreground hover:translate-y-[-1px]" onClick={onShare}>
          Share Result
        </button>
      </div>
    </div>
  );
}
