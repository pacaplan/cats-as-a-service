import React from 'react';

interface PageHeroProps {
  title: string;
  subtitle: string;
  meta?: string;
  steps?: Array<{ label: string; active?: boolean }>;
}

export default function PageHero({ title, subtitle, meta, steps }: PageHeroProps) {
  return (
    <section className="mt-1 p-[18px_20px] rounded-lg bg-secondary text-secondary-foreground flex flex-col gap-2">
      <div className="flex flex-col gap-1">
        <div className="text-[26px] font-bold">{title}</div>
        <div className="text-[13px] max-w-[640px]">{subtitle}</div>
      </div>
      {meta && <div className="text-[11px] text-muted-foreground">{meta}</div>}
      {steps && steps.length > 0 && (
        <div className="flex gap-2 text-[11px] mt-[2px] flex-wrap">
          {steps.map((step, index) => (
            <div
              key={index}
              className={`px-2 py-1 rounded-full ${step.active ? 'bg-primary text-primary-foreground' : 'bg-card text-card-foreground'}`}
            >
              {step.label}
            </div>
          ))}
        </div>
      )}
    </section>
  );
}

