import React from 'react';

interface FAQItemProps {
  question: string;
  answer: string;
  tag: string;
  note?: string;
  linkText?: string;
  linkUrl?: string;
}

export default function FAQItem({ question, answer, tag, note, linkText, linkUrl }: FAQItemProps) {
  return (
    <article className="rounded-lg bg-card text-card-foreground p-[10px_12px] flex flex-col gap-1">
      <div className="flex justify-between items-start gap-2">
        <div className="text-[14px] font-semibold">{question}</div>
        <div className="text-[11px] px-[6px] py-[2px] rounded-full bg-muted text-muted-foreground">{tag}</div>
      </div>
      <div className="text-[13px] text-foreground leading-[1.5]">
        {answer}
        {linkText && linkUrl && (
          <a href={linkUrl} target="_blank" rel="noopener noreferrer" className="text-accent-foreground bg-accent rounded-md px-[6px] py-[2px] text-[11px] font-medium inline-flex items-center gap-1 ml-1">
            {linkText}
          </a>
        )}
      </div>
      {note && <div className="text-[11px] text-muted-foreground mt-[2px]">{note}</div>}
    </article>
  );
}

