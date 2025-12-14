import React from 'react';
import { CatPreviewState } from './types';

type Props = {
  preview: CatPreviewState;
  onSelectName: (name: string) => void;
  onRegenerate: () => void;
  onRequestChanges: () => void;
  onSave: () => void;
};

export default function CatPreview({
  preview,
  onSelectName,
  onRegenerate,
  onRequestChanges,
  onSave,
}: Props) {
  const selectedName = preview.customName?.trim() || preview.name;

  return (
    <div className="bg-card border border-[rgba(31,27,36,0.08)] rounded-xl p-4 flex flex-col gap-3 shadow-[0_12px_30px_rgba(31,27,36,0.06)]">
      <div className="flex items-center justify-between">
        <div className="font-bold text-base">Cat preview</div>
        <div className="bg-secondary text-secondary-foreground rounded-full px-2.5 py-1 text-xs font-bold">
          {preview.status === 'ready' ? 'Ready' : 'In progress'}
        </div>
      </div>
      <div className="bg-muted rounded-lg p-3 flex flex-col gap-2">
        {preview.imageUrl ? (
          <img src={preview.imageUrl} alt={selectedName} className="w-full rounded-lg" />
        ) : (
          <div
            className="bg-gradient-to-r from-[rgba(255,255,255,0.3)] via-[rgba(255,255,255,0.6)] to-[rgba(255,255,255,0.3)] bg-[length:200px_100%] animate-shimmer rounded-lg p-4 flex flex-col items-center gap-2 min-h-[140px] justify-center text-muted-foreground text-center"
          >
            <div className="text-[28px]">🐾</div>
            <div className="text-sm font-semibold">
              {preview.status === 'generating'
                ? 'Rendering your cat...'
                : 'Image arrives after CatBot finishes.'}
            </div>
          </div>
        )}
        {preview.status === 'generating' && (
          <div className="relative bg-[#f0e9fc] rounded-md h-2 overflow-hidden">
            <div
              className="bg-gradient-to-r from-[#ff8c42] to-[#ffb36f] h-full transition-[width] duration-300 ease-in-out"
              style={{ width: `${preview.progress}%` }}
            />
            <div className="text-xs text-muted-foreground mt-1 self-end">{preview.progress}%</div>
          </div>
        )}
      </div>
      <div className="flex flex-col gap-2">
        <div className="text-[13px] font-bold text-muted-foreground">Pick a name</div>
        <div className="grid grid-cols-[repeat(auto-fit,minmax(120px,1fr))] gap-2">
          {preview.nameOptions.map((option) => (
            <label key={option} className="flex items-center gap-2 bg-muted rounded-md px-2.5 py-2 cursor-pointer font-semibold">
              <input
                type="radio"
                name="cat-name"
                value={option}
                checked={selectedName === option}
                onChange={() => onSelectName(option)}
                className="cursor-pointer"
              />
              <span>{option}</span>
            </label>
          ))}
        </div>
        <label className="flex flex-col gap-1.5 text-[13px] font-semibold">
          <span>Or type your own</span>
          <input
            type="text"
            placeholder="Captain Whiskertron"
            value={preview.customName ?? ''}
            onChange={(event) => onSelectName(event.target.value)}
            className="py-2.5 px-3 border border-[rgba(31,27,36,0.1)] rounded-md bg-white"
          />
        </label>
      </div>
      <div className="flex flex-col gap-2">
        <div className="text-[13px] font-bold text-muted-foreground">Description</div>
        <p className="text-foreground leading-[1.5]">{preview.description}</p>
      </div>
      <div className="grid grid-cols-[repeat(auto-fit,minmax(140px,1fr))] gap-2">
        <button
          className="py-3 px-3.5 rounded-md font-bold border-none cursor-pointer transition-[transform,box-shadow] duration-[0.08s,0.12s] ease-[ease,ease] bg-[#fff6eb] text-[#5a3416] border border-[rgba(255,140,66,0.3)] hover:-translate-y-px"
          onClick={onRegenerate}
        >
          Regenerate Image
        </button>
        <button
          className="py-3 px-3.5 rounded-md font-bold border-none cursor-pointer transition-[transform,box-shadow] duration-[0.08s,0.12s] ease-[ease,ease] bg-[#fff6eb] text-[#5a3416] border border-[rgba(255,140,66,0.3)] hover:-translate-y-px"
          onClick={onRequestChanges}
        >
          Request Changes
        </button>
        <button
          className="py-3 px-3.5 rounded-md font-bold border-none cursor-pointer transition-[transform,box-shadow] duration-[0.08s,0.12s] ease-[ease,ease] bg-primary text-primary-foreground shadow-[0_10px_20px_rgba(255,140,66,0.25)] hover:-translate-y-px"
          onClick={onSave}
        >
          Save Cat
        </button>
      </div>
    </div>
  );
}
