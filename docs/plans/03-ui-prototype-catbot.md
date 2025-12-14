# CatBot Quiz and Chat UI Implementation

## Route Structure

Update the existing `/catbot` route at [apps/web/app/catbot/page.tsx](apps/web/app/catbot/page.tsx) to implement the full quiz and chat flow.

## Implementation Approach

### 1. Quiz Flow State Management

Create a client component that manages quiz state:

- Quiz introduction screen
- 4 question screens with progress tracking
- Quiz result screen with personality match
- Ability to skip to CatBot at any point
- Navigation between quiz steps

### 2. Quiz Components

New files in `apps/web/components/catbot/`:

- `QuizIntro.tsx` + `QuizIntro.module.css` - Introduction screen with ASCII cat art, "Start Quiz" and "Skip to CatBot" buttons
- `QuizQuestion.tsx` + `QuizQuestion.module.css` - Reusable question component with:
  - Question text in styled box
  - 4 option buttons with emoji icons and descriptions
  - Progress indicator (filled/empty circles)
  - Back button and "Skip to CatBot" link
  - Question counter (e.g., "Question 1 of 4")
- `QuizResult.tsx` + `QuizResult.module.css` - Result screen showing:
  - Personality match name (e.g., "Chaotic Gremlin")
  - Description based on quiz answers
  - ASCII cat art
  - "Create This Cat with CatBot" button
  - "Retake Quiz" button
  - "Share Result" button with shareable text

### 3. CatBot Chat Components

New files in `apps/web/components/catbot/`:

- `CatBotChat.tsx` + `CatBotChat.module.css` - Main chat container with:
  - Chat header with cat ASCII art
  - Scrollable message history area
  - Input area with paw print decoration and send button
- `ChatMessage.tsx` + `ChatMessage.module.css` - Individual message component:
  - CatBot messages (left-aligned) with paw print decoration
  - User messages (right-aligned)
  - Support for cat actions (e.g., "*Purrs excitedly*")
  - Support for name suggestions (radio buttons)
  - Support for image generation progress
  - Support for cat preview with image placeholder
- `CatPreview.tsx` + `CatPreview.module.css` - Cat preview panel showing:
  - Image placeholder (or generated image)
  - Name selection (3 radio options + custom input)
  - Action buttons: "Regenerate Image", "Request Changes", "Save Cat"
  - Description text

### 4. Quiz Data Structure

Create `apps/web/data/quiz.ts`:

- Question definitions with options (emoji, label, description)
- Personality match logic (maps quiz answers to personality types)
- Personality descriptions and names

### 5. Mock CatBot Responses

Create `apps/web/data/catbotResponses.ts`:

- Mock responses for different user inputs
- Pre-defined name suggestions
- Mock descriptions
- Simulated image generation progress

### 6. Main CatBot Page

Update [apps/web/app/catbot/page.tsx](apps/web/app/catbot/page.tsx):

- Client component with state management for:
  - Current step (intro, question1-4, result, chat)
  - Quiz answers
  - Chat messages array
  - Current cat being created (name, description, image status)
- Conditional rendering based on current step
- Navigation handlers (next question, skip to chat, etc.)

### 7. Styling Approach

- Follow existing CSS Modules pattern
- Use cat-themed elements from mockups:
  - Paw print (🐾) icons
  - ASCII cat art for headers
  - Cat-themed language ("purrfect", "meow", etc.)
- Chat bubbles styled as shown in mockups
- Progress indicators (filled/empty circles for quiz)
- Loading states with cat ASCII art

### 8. Mock Interactions

- Quiz: Store answers in state, calculate personality match
- Chat: Add user messages to array, simulate CatBot responses with delays
- Name selection: Radio button selection
- Image generation: Simulate progress bar (0% → 100%)
- Save cat: Show success screen, add to cart (mock)

### 9. Navigation Integration

- "Skip to CatBot" buttons navigate to chat interface
- "Create This Cat with CatBot" from result screen transitions to chat
- Chat can be accessed directly from quiz intro
- Back navigation within quiz flow

## Component Hierarchy

```
CatBotPage (client component)
├── QuizIntro (if step === 'intro')
├── QuizQuestion (if step === 'question1-4')
├── QuizResult (if step === 'result')
└── CatBotChat (if step === 'chat')
    ├── ChatMessage (multiple)
    └── CatPreview (when cat is generated)
```

## Mock Data Examples

Quiz questions match requirements:

- Q1: Energy level (4 options)
- Q2: Superpower (4 options)
- Q3: Dream vacation (4 options)
- Q4: Cat aesthetic (4 options)

Personality matches include:

- "Chaotic Gremlin" (from mockups)
- Other personality types based on answer combinations

CatBot mock responses:

- Welcome message referencing quiz results (if taken)
- Name suggestions (3 options)
- Cat descriptions
- Simulated image generation

## UI-Only Behavior

- No actual LLM API calls
- Mock responses based on user input patterns
- Simulated delays for "thinking" and image generation
- Quiz results calculated client-side from answer combinations
- Saved cats stored in component state (not persisted)