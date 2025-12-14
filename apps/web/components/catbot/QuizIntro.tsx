import React from 'react';

type Props = {
  onStart: () => void;
  onSkip: () => void;
};

export default function QuizIntro({ onStart, onSkip }: Props) {
  return (
    <div className="bg-gradient-to-br from-[#fff3e4] to-[#f0eaff] rounded-[18px] border border-[rgba(31,27,36,0.08)] p-5 flex flex-col gap-3 shadow-[0_18px_36px_rgba(31,27,36,0.08)]">
      <div className="self-start bg-white text-[#5b436d] rounded-full px-3 py-[6px] font-extrabold tracking-[0.02em] border border-dashed border-[rgba(31,27,36,0.12)]">Cat personality quiz</div>
      <pre className="bg-white rounded-lg p-[10px] font-mono text-[14px] leading-[1.4] w-fit border border-[rgba(31,27,36,0.06)]">{String.raw`
 /\_/\   meow
( =^.^=)ﾉ
 (")(")  ~`}</pre>
      <h1 className="text-[26px]">Let&apos;s meet your dream cat</h1>
      <p className="text-muted-foreground leading-[1.6] max-w-[720px]">
        Answer four playful questions to unlock a CatBot personality match. You can jump straight to
        chat if you&apos;re feeling impulsive.
      </p>
      <div className="flex gap-[10px] flex-wrap">
        <button className="px-4 py-3 rounded-xl font-extrabold border-none cursor-pointer bg-primary text-primary-foreground shadow-[0_12px_24px_rgba(255,140,66,0.25)]" onClick={onStart}>
          Start Quiz
        </button>
        <button className="px-4 py-3 rounded-xl font-extrabold border border-[rgba(31,27,36,0.1)] cursor-pointer bg-white text-foreground" onClick={onSkip}>
          Skip to CatBot
        </button>
      </div>
      <div className="text-[13px] text-muted-foreground flex gap-2 items-center">
        <span>Includes ASCII cats, paw prints, and zero judgment.</span>
      </div>
    </div>
  );
}
