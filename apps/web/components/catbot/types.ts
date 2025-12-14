export type CatPreviewState = {
  name: string;
  description: string;
  nameOptions: string[];
  customName?: string;
  status: 'idle' | 'thinking' | 'generating' | 'ready';
  progress: number;
  imageUrl?: string;
};

export type ChatMessage = {
  id: string;
  sender: 'bot' | 'user';
  text: string;
  action?: string;
  nameSuggestions?: string[];
  imageProgress?: number;
  catPreview?: Partial<CatPreviewState>;
};
