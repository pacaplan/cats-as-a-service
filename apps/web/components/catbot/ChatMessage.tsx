import React from 'react';
import { ChatMessage as ChatMessageType } from './types';

type Props = {
  message: ChatMessageType;
  onSelectName?: (name: string) => void;
  selectedName?: string;
};

export default function ChatMessage({ message, onSelectName, selectedName }: Props) {
  const isUser = message.sender === 'user';

  return (
    <div className={`flex gap-2.5 items-start ${isUser ? 'flex-row-reverse' : ''}`}>
      <div className="w-8 h-8 rounded-xl bg-white border border-[rgba(31,27,36,0.08)] grid place-items-center text-lg">
        {isUser ? '😸' : '🤖'}
      </div>
      <div
        className={`rounded-lg p-3 max-w-[520px] flex flex-col gap-2 ${
          isUser
            ? 'bg-gradient-to-br from-[#ffb36f] to-[#ff8c42] text-[#1f1b24] shadow-[0_10px_20px_rgba(255,140,66,0.28)]'
            : 'bg-[#f5f1ff] border border-[rgba(31,27,36,0.05)]'
        }`}
      >
        <div className="leading-[1.5] font-semibold">{message.text}</div>
        {message.action && <div className="text-[#5b436d] italic font-semibold">{message.action}</div>}
        {message.nameSuggestions && onSelectName && (
          <div className="flex flex-col gap-1.5">
            <div className="text-xs uppercase tracking-[0.03em] text-muted-foreground font-bold">Name sparks</div>
            {message.nameSuggestions.map((name) => (
              <label
                key={name}
                className="flex items-center gap-2 bg-white rounded-md px-2.5 py-2 border border-dashed border-[rgba(31,27,36,0.14)] font-semibold cursor-pointer"
              >
                <input
                  type="radio"
                  name="name-suggestion"
                  value={name}
                  checked={selectedName === name}
                  onChange={() => onSelectName(name)}
                  className="cursor-pointer"
                />
                <span>{name}</span>
              </label>
            ))}
          </div>
        )}
        {typeof message.imageProgress === 'number' && (
          <div className="flex items-center gap-2">
            <div className="flex-1 h-2 bg-[rgba(31,27,36,0.08)] rounded-full overflow-hidden">
              <div
                className="h-full bg-gradient-to-r from-[#c8b7ff] to-[#8c7cf8]"
                style={{ width: `${Math.min(100, message.imageProgress)}%` }}
              />
            </div>
            <div className="text-xs font-bold text-muted-foreground">{message.imageProgress}%</div>
          </div>
        )}
        {message.catPreview && (
          <div className="border border-[rgba(31,27,36,0.08)] rounded-md p-2.5 bg-white flex flex-col gap-1.5">
            <div className="font-bold">{message.catPreview.name || 'New Cat'}</div>
            <div className="text-muted-foreground leading-[1.4]">{message.catPreview.description}</div>
            <div className="self-start bg-[#fff6eb] text-[#5a3416] rounded-full px-2.5 py-1 text-xs font-bold">
              {message.catPreview.status === 'ready' ? 'Preview' : 'Sketching'}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
