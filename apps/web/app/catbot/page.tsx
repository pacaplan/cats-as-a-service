'use client';

import React, { useState, useEffect, useCallback, useRef } from 'react';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import QuizIntro from '@/components/catbot/QuizIntro';
import QuizQuestion from '@/components/catbot/QuizQuestion';
import QuizResult from '@/components/catbot/QuizResult';
import CatBotChat from '@/components/catbot/CatBotChat';
import { quizQuestions, calculatePersonality, PersonalityMatch } from '@/data/quiz';
import {
  buildWelcomeMessage,
  pickMockResponse,
  pickCatDescription,
  nextCatAction,
  mockNameSuggestions,
  imageProgress,
} from '@/data/catbotResponses';
import { ChatMessage, CatPreviewState } from '@/components/catbot/types';

type Step = 'intro' | 'question1' | 'question2' | 'question3' | 'question4' | 'result' | 'chat';

export default function CatBotPage() {
  const [step, setStep] = useState<Step>('intro');
  const [quizAnswers, setQuizAnswers] = useState<Record<string, string>>({});
  const [personalityMatch, setPersonalityMatch] = useState<PersonalityMatch | null>(null);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [isThinking, setIsThinking] = useState(false);
  const [selectedName, setSelectedName] = useState<string>('');
  const [catPreview, setCatPreview] = useState<CatPreviewState | null>(null);
  const [messageCounter, setMessageCounter] = useState(0);
  const [actionCounter, setActionCounter] = useState(0);
  const imageGenerationIntervalRef = useRef<NodeJS.Timeout | null>(null);
  const messageCounterRef = useRef(0);
  const actionCounterRef = useRef(0);

  // Initialize chat with welcome message when entering chat
  useEffect(() => {
    if (step === 'chat' && messages.length === 0) {
      const welcomeText = buildWelcomeMessage(personalityMatch);
      const initialMessage: ChatMessage = {
        id: 'welcome',
        sender: 'bot',
        text: welcomeText,
      };
      if (!personalityMatch) {
        initialMessage.nameSuggestions = mockNameSuggestions;
      }
      setMessages([initialMessage]);
    }
  }, [step, personalityMatch, messages.length]);

  // Cleanup interval on unmount
  useEffect(() => {
    return () => {
      if (imageGenerationIntervalRef.current) {
        clearInterval(imageGenerationIntervalRef.current);
        imageGenerationIntervalRef.current = null;
      }
    };
  }, []);

  const handleStartQuiz = () => {
    setStep('question1');
    setQuizAnswers({});
  };

  const handleSkipToChat = () => {
    setStep('chat');
  };

  const handleSelectOption = (questionId: string, optionId: string) => {
    const newAnswers = { ...quizAnswers, [questionId]: optionId };
    setQuizAnswers(newAnswers);

    const currentQuestionIndex = quizQuestions.findIndex((q) => q.id === questionId);
    if (currentQuestionIndex < quizQuestions.length - 1) {
      const nextQuestion = quizQuestions[currentQuestionIndex + 1];
      setStep(`question${currentQuestionIndex + 2}` as Step);
    } else {
      // Last question answered, calculate personality and show result
      const match = calculatePersonality(newAnswers);
      setPersonalityMatch(match);
      setStep('result');
    }
  };

  const handleBack = () => {
    if (step === 'question2') {
      setStep('question1');
    } else if (step === 'question3') {
      setStep('question2');
    } else if (step === 'question4') {
      setStep('question3');
    }
  };

  const handleRetakeQuiz = () => {
    setStep('intro');
    setQuizAnswers({});
    setPersonalityMatch(null);
  };

  const handleCreateCat = () => {
    setStep('chat');
  };

  const handleShare = () => {
    if (personalityMatch) {
      const shareText = personalityMatch.shareText;
      if (navigator.share) {
        navigator.share({
          title: 'My CatBot Personality Match',
          text: shareText,
        });
      } else {
        // Fallback: copy to clipboard
        navigator.clipboard.writeText(shareText);
        alert('Result copied to clipboard!');
      }
    }
  };

  const simulateImageGeneration = useCallback(() => {
    // Clear any existing interval before starting a new one
    if (imageGenerationIntervalRef.current) {
      clearInterval(imageGenerationIntervalRef.current);
      imageGenerationIntervalRef.current = null;
    }

    let progressIndex = 0;
    const progressInterval = setInterval(() => {
      if (progressIndex < imageProgress.length) {
        const { progress, text } = imageProgress[progressIndex];
        setCatPreview((prev) => {
          if (!prev) return null;
          return {
            ...prev,
            progress,
            status: 'generating',
          };
        });

        // Update last message with progress
        setMessages((prev) => {
          const updated = [...prev];
          const lastBotMessage = [...updated].reverse().find((m) => m.sender === 'bot');
          if (lastBotMessage) {
            const index = updated.findIndex((m) => m.id === lastBotMessage.id);
            if (index !== -1) {
              updated[index] = {
                ...updated[index],
                imageProgress: progress,
              };
            }
          }
          return updated;
        });

        progressIndex++;
      } else {
        clearInterval(progressInterval);
        imageGenerationIntervalRef.current = null;
        // Image generation complete
        setCatPreview((prev) => {
          if (!prev) return null;
          return {
            ...prev,
            progress: 100,
            status: 'ready',
            imageUrl: undefined, // Placeholder - no actual image URL
          };
        });
      }
    }, 800);

    // Store the interval reference
    imageGenerationIntervalRef.current = progressInterval;
  }, []);

  const handleSendMessage = (text: string) => {
    // Add user message
    const userMessage: ChatMessage = {
      id: `user-${Date.now()}`,
      sender: 'user',
      text,
    };
    setMessages((prev) => [...prev, userMessage]);
    setIsThinking(true);

    // Capture current counter values and increment refs immediately
    const currentActionIndex = actionCounterRef.current;
    const currentMessageIndex = messageCounterRef.current;
    actionCounterRef.current += 1;
    messageCounterRef.current += 1;

    // Update state for display purposes (though not used in the closure)
    setActionCounter(actionCounterRef.current);
    setMessageCounter(messageCounterRef.current);

    // Simulate bot thinking and response
    setTimeout(() => {
      setIsThinking(false);
      const action = nextCatAction(currentActionIndex);
      const mockResponse = pickMockResponse(currentMessageIndex);

      const botMessage: ChatMessage = {
        id: `bot-${Date.now()}`,
        sender: 'bot',
        text: mockResponse,
        action: action.text,
      };

      // Check if user is asking to create a cat
      const lowerText = text.toLowerCase();
      if (
        lowerText.includes('create') ||
        lowerText.includes('build') ||
        lowerText.includes('make') ||
        lowerText.includes('generate')
      ) {
        const description = pickCatDescription(personalityMatch);
        const nameOptions = [...mockNameSuggestions];
        botMessage.nameSuggestions = nameOptions;

        // Start cat preview generation
        const preview: CatPreviewState = {
          name: nameOptions[0],
          description,
          nameOptions,
          status: 'thinking',
          progress: 0,
        };
        setCatPreview(preview);
        setSelectedName(nameOptions[0]);

        // Start image generation simulation
        setTimeout(() => {
          simulateImageGeneration();
        }, 1000);
      }

      setMessages((prev) => [...prev, botMessage]);
    }, 1500);
  };

  const handleSelectName = (name: string) => {
    setSelectedName(name);
    setCatPreview((prev) => {
      if (!prev) return null;
      // Check if the name is one of the predefined options
      const isPredefinedOption = prev.nameOptions.includes(name);
      return {
        ...prev,
        customName: isPredefinedOption ? undefined : name,
      };
    });
  };

  const handleRegenerate = () => {
    if (catPreview) {
      setCatPreview({
        ...catPreview,
        status: 'generating',
        progress: 0,
        imageUrl: undefined,
      });
      simulateImageGeneration();
    }
  };

  const handleRequestChanges = () => {
    setIsThinking(true);
    // Capture current counter value and increment ref immediately
    const currentActionIndex = actionCounterRef.current;
    actionCounterRef.current += 1;
    setActionCounter(actionCounterRef.current);

    setTimeout(() => {
      setIsThinking(false);
      const action = nextCatAction(currentActionIndex);
      const botMessage: ChatMessage = {
        id: `bot-${Date.now()}`,
        sender: 'bot',
        text: 'What would you like me to change?',
        action: action.text,
      };
      setMessages((prev) => [...prev, botMessage]);
    }, 1000);
  };

  const handleSave = () => {
    alert('Cat saved! (This is a mock - no actual persistence)');
    // In a real app, this would add the cat to the cart or save it
  };

  const getCurrentQuestion = () => {
    if (step === 'question1') return quizQuestions[0];
    if (step === 'question2') return quizQuestions[1];
    if (step === 'question3') return quizQuestions[2];
    if (step === 'question4') return quizQuestions[3];
    return null;
  };

  const getQuestionNumber = () => {
    if (step === 'question1') return 1;
    if (step === 'question2') return 2;
    if (step === 'question3') return 3;
    if (step === 'question4') return 4;
    return 0;
  };

  return (
    <div className="bg-background text-foreground min-h-screen flex flex-col">
      <div className="max-w-[1120px] mx-auto p-[24px_32px_40px_32px] flex flex-col gap-6">
        <Header />
        <main className="p-5 bg-card rounded-lg text-muted-foreground">
          {step === 'intro' && (
            <QuizIntro onStart={handleStartQuiz} onSkip={handleSkipToChat} />
          )}
          {step.startsWith('question') && getCurrentQuestion() && (
            <QuizQuestion
              question={getCurrentQuestion()}
              questionNumber={getQuestionNumber()}
              totalQuestions={quizQuestions.length}
              selectedOptionId={quizAnswers[getCurrentQuestion()!.id]}
              onSelectOption={(optionId) =>
                handleSelectOption(getCurrentQuestion()!.id, optionId)
              }
              onBack={handleBack}
              onSkip={handleSkipToChat}
            />
          )}
          {step === 'result' && personalityMatch && (
            <QuizResult
              personalityMatch={personalityMatch}
              onCreateCat={handleCreateCat}
              onRetake={handleRetakeQuiz}
              onShare={handleShare}
            />
          )}
          {step === 'chat' && (
            <CatBotChat
              messages={messages}
              onSendMessage={handleSendMessage}
              isThinking={isThinking}
              onSelectName={handleSelectName}
              selectedName={selectedName}
              catPreview={catPreview}
              onRegenerate={handleRegenerate}
              onRequestChanges={handleRequestChanges}
              onSave={handleSave}
              personalityMatch={personalityMatch}
            />
          )}
        </main>
        <Footer />
      </div>
    </div>
  );
}
