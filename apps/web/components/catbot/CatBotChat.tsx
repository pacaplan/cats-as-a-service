'use client';

import React, { useEffect, useMemo, useRef, useState } from 'react';
import { PersonalityMatch } from '@/data/quiz';
import { catbotHeaderArt } from '@/data/catbotResponses';
import ChatMessage from './ChatMessage';
import CatPreview from './CatPreview';
import { CatPreviewState, ChatMessage as ChatMessageType } from './types';

type Props = {
  messages: ChatMessageType[];
  onSendMessage: (text: string) => void;
  isThinking: boolean;
  onSelectName: (name: string) => void;
  selectedName: string;
  catPreview: CatPreviewState | null;
  onRegenerate: () => void;
  onRequestChanges: () => void;
  onSave: () => void;
  personalityMatch?: PersonalityMatch | null;
};

export default function CatBotChat({
  messages,
  onSendMessage,
  isThinking,
  onSelectName,
  selectedName,
  catPreview,
  onRegenerate,
  onRequestChanges,
  onSave,
  personalityMatch,
}: Props) {
  const [draft, setDraft] = useState('');
  const scrollRef = useRef<HTMLDivElement | null>(null);

  const placeholder = useMemo(() => {
    if (personalityMatch) {
      return `Ask CatBot to build a ${personalityMatch.name.toLowerCase()}...`;
    }
    return 'Describe your dream cat or ask for a change...';
  }, [personalityMatch]);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages, isThinking]);

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    const value = draft.trim();
    if (!value) return;
    onSendMessage(value);
    setDraft('');
  };

  return (
    <div className="bg-gradient-to-br from-[#fff8f0] to-[#f1ecff] border border-[rgba(31,27,36,0.08)] rounded-2xl p-4 flex flex-col gap-3 shadow-[0_16px_36px_rgba(31,27,36,0.08)]">
      <div className="grid grid-cols-[180px_1fr] gap-4 items-center">
        <pre className="bg-white border border-dashed border-[rgba(31,27,36,0.14)] rounded-lg p-3 font-mono text-[13px] leading-[1.4]">
          {catbotHeaderArt}
        </pre>
        <div>
          <div className="text-xs text-muted-foreground uppercase tracking-[0.08em] font-extrabold">CatBot chat</div>
          <h2 className="my-1 text-[22px]">
            Let&apos;s build {personalityMatch ? `your ${personalityMatch.name}` : 'a cat'} together
          </h2>
          <p className="text-muted-foreground leading-[1.5]">
            Share vibes, pick a name, and I will conjure a preview with paw-level precision.
          </p>
        </div>
      </div>
      <div className="grid grid-cols-[2fr_1fr] gap-3 max-[920px]:grid-cols-1">
        <div
          className="bg-white rounded-lg border border-[rgba(31,27,36,0.08)] p-3 h-[420px] max-[920px]:h-[360px] overflow-y-auto flex flex-col gap-3"
          ref={scrollRef}
        >
          {messages.map((message) => (
            <ChatMessage
              key={message.id}
              message={message}
              onSelectName={onSelectName}
              selectedName={selectedName}
            />
          ))}
          {isThinking && (
            <div className="flex items-center gap-2.5 p-2.5 rounded-md border border-dashed border-[rgba(31,27,36,0.1)] bg-[#f5f1ff]">
              <div className="text-lg">🐾</div>
              <div className="flex gap-1">
                <span className="w-2 h-2 rounded-full bg-[#a092ff] animate-pulse-dot" />
                <span className="w-2 h-2 rounded-full bg-[#a092ff] animate-pulse-dot [animation-delay:0.15s]" />
                <span className="w-2 h-2 rounded-full bg-[#a092ff] animate-pulse-dot [animation-delay:0.3s]" />
              </div>
              <div className="font-bold text-[#5b436d]">CatBot is thinking...</div>
            </div>
          )}
        </div>
        <div className="min-w-[260px]">
          {catPreview && (
            <CatPreview
              preview={catPreview}
              onSelectName={onSelectName}
              onRegenerate={onRegenerate}
              onRequestChanges={onRequestChanges}
              onSave={onSave}
            />
          )}
        </div>
      </div>
      <form className="flex gap-2.5 items-center" onSubmit={handleSubmit}>
        <div className="flex-1 flex items-center gap-2 bg-white border border-[rgba(31,27,36,0.1)] rounded-full py-2.5 px-3.5">
          <span className="text-base">🐾</span>
          <input
            type="text"
            value={draft}
            onChange={(event) => setDraft(event.target.value)}
            placeholder={placeholder}
            className="border-none outline-none flex-1 text-sm"
          />
        </div>
        <button
          type="submit"
          className="bg-primary text-primary-foreground border-none rounded-full py-3 px-4 font-extrabold cursor-pointer shadow-[0_12px_24px_rgba(255,140,66,0.28)] disabled:opacity-60 disabled:cursor-not-allowed disabled:shadow-none"
          disabled={!draft.trim()}
        >
          Send
        </button>
      </form>
    </div>
  );
}
