import React from 'react';
import { QuizQuestion as QuizQuestionType } from '@/data/quiz';

type Props = {
  question: QuizQuestionType;
  questionNumber: number;
  totalQuestions: number;
  selectedOptionId?: string;
  onSelectOption: (optionId: string) => void;
  onBack: () => void;
  onSkip: () => void;
};

export default function QuizQuestion({
  question,
  questionNumber,
  totalQuestions,
  selectedOptionId,
  onSelectOption,
  onBack,
  onSkip,
}: Props) {
  return (
    <div className="bg-gradient-to-br from-[#fff3e4] to-[#f0eaff] rounded-[18px] border border-[rgba(31,27,36,0.08)] p-6 flex flex-col gap-4 shadow-[0_18px_36px_rgba(31,27,36,0.08)]">
      <div className="flex justify-between items-center gap-4">
        <div className="text-[14px] font-bold text-muted-foreground">
          Question {questionNumber} of {totalQuestions}
        </div>
        <div className="flex gap-2">
          {Array.from({ length: totalQuestions }).map((_, i) => (
            <div
              key={i}
              className={`w-[10px] h-[10px] rounded-full border-2 ${
                i < questionNumber
                  ? 'bg-primary border-primary'
                  : 'bg-[rgba(31,27,36,0.1)] border-[rgba(31,27,36,0.2)]'
              }`}
            />
          ))}
        </div>
      </div>
      <div className="bg-white rounded-lg p-5 border border-[rgba(31,27,36,0.08)]">
        <h2 className="text-[22px] mb-2">{question.prompt}</h2>
        <p className="text-muted-foreground leading-[1.5]">{question.detail}</p>
      </div>
      <div className="grid grid-cols-[repeat(auto-fit,minmax(240px,1fr))] gap-3">
        {question.options.map((option) => (
          <button
            key={option.id}
            className={`bg-white border-2 rounded-lg p-4 flex gap-3 items-start cursor-pointer transition-all duration-200 ease-in-out text-left hover:border-primary hover:translate-y-[-2px] hover:shadow-[0_8px_16px_rgba(255,140,66,0.15)] ${
              selectedOptionId === option.id
                ? 'border-primary bg-[#fff6eb] shadow-[0_8px_16px_rgba(255,140,66,0.2)]'
                : 'border-[rgba(31,27,36,0.1)]'
            }`}
            onClick={() => onSelectOption(option.id)}
          >
            <span className="text-[32px] leading-none">{option.emoji}</span>
            <div className="flex-1 flex flex-col gap-1">
              <div className="font-bold text-[16px] mb-1">{option.label}</div>
              <div className="text-[13px] text-muted-foreground leading-[1.4]">{option.description}</div>
            </div>
          </button>
        ))}
      </div>
      <div className="flex justify-between items-center gap-4">
        <button className="px-4 py-[10px] rounded-md font-semibold border border-[rgba(31,27,36,0.1)] bg-white text-foreground cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed" onClick={onBack} disabled={questionNumber === 1}>
          Back
        </button>
        <button className="bg-none border-none text-primary font-semibold cursor-pointer underline text-[14px] hover:opacity-80" onClick={onSkip}>
          Skip to CatBot
        </button>
      </div>
    </div>
  );
}
