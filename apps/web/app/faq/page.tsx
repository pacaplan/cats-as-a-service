import React from 'react';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import PageHero from '@/components/layout/PageHero';
import FAQItem from '@/components/faq/FAQItem';
import FAQAside from '@/components/faq/FAQAside';

const faqData = [
  {
    question: 'Is this real?',
    answer: "Sure... in the same way a Schrödinger cat meme is real. This is a lovingly over‑built demo shop for entirely fictional, AI‑imagined cats. You can browse, \"buy,\" and customize to your heart's content — but no actual felines, payments, or deliveries exist behind the curtain.",
    tag: 'Foundational concern'
  },
  {
    question: 'Like — really?',
    answer: "Of course not, silly! The cart doesn't charge anything, the cats aren't sentient (yet), and no one is secretly mailing you a box of quantum meows. This is a safe space for whimsical UI, fake prices expressed in ¢, and maximum cat puns.",
    tag: 'Double‑checking'
  },
  {
    question: 'Then why does this exist?',
    answer: 'I am available for work as a software engineer. This is my purr‑tfolio — a playground to show product thinking, UX decisions, and front‑end implementation. If you\'re a recruiter, hiring manager, or future teammate, you can inspect the code and architecture here:',
    tag: 'Developer disclosure',
    linkText: 'github.com/pacaplan/rampart',
    linkUrl: 'https://github.com/pacaplan/rampart',
    note: 'Yes, that link is manually typed on purpose so you can see it clearly in screenshots and screen recordings.'
  },
  {
    question: 'But I need a cat!',
    answer: 'There are many excellent models available for adoption — fully trained, frequently chaotic, and absolutely real. You can start your search here:',
    tag: 'Important priority',
    linkText: 'aspca.org/adopt-pet/find-shelter',
    linkUrl: 'https://www.aspca.org/adopt-pet/find-shelter'
  },
  {
    question: 'What is CatBot actually doing?',
    answer: "From a user's perspective, CatBot takes your free‑text description, invents a name, personality, and a fictional glamour shot, then lets you tweak the vibe before saving it as a pretend product. From an engineering perspective, it's a structured prompt and response flow with light post‑processing to keep the UX feeling coherent and playful.",
    tag: 'Product behavior'
  },
  {
    question: 'Can I really "buy" these cats?',
    answer: "You can add as many cats as you like to your cart, proceed to a fake checkout, and admire your impeccable taste in imaginary companions. But there are no real payments, no Stripe keys, and no shipping — just a carefully staged illusion of e‑commerce for demonstration purposes.",
    tag: 'Commerce disclaimer'
  },
  {
    question: 'What skills is this project meant to show?',
    answer: 'This Cat‑alog is designed to demonstrate product thinking (clear flows, guest vs. registered behavior), front‑end implementation (layout, stateful components like mini‑cart, builder panels), and general attention to UX copy and edge cases. Think of it as a miniature product instead of a single coding exercise.',
    tag: 'For recruiters'
  },
  {
    question: 'Can I reuse any of this?',
    answer: "Absolutely. If you find patterns you like — layout ideas, copy, or flows for playful AI tools — feel free to adapt them. If you're evaluating me as a candidate, you're warmly invited to clone the repo, run it locally, and poke at the internals.",
    tag: 'Practical matters'
  }
];

export default function FAQPage() {
  return (
    <div className="bg-background text-foreground min-h-screen flex flex-col">
      <div className="max-w-[1120px] mx-auto p-[24px_32px_40px_32px] flex flex-col gap-6">
        <Header />
        <PageHero
          title="FAQ & About This Cat‑periment"
          subtitle="Publicly visible answers for curious humans, recruiters, and anyone wondering if they've accidentally stumbled into a real cat store (you have not)."
          meta="Spoiler: everything here is imaginary, but the code and the human who wrote it are very real."
        />
        <main className="flex gap-5 items-start">
          <section className="flex-1 flex flex-col gap-3">
            <div className="text-xs text-muted-foreground uppercase tracking-[0.08em] font-extrabold">
              Core questions humans keep asking
            </div>
            <div className="flex flex-col gap-2">
              {faqData.map((faq, index) => (
                <FAQItem
                  key={index}
                  question={faq.question}
                  answer={faq.answer}
                  tag={faq.tag}
                  note={faq.note}
                  linkText={faq.linkText}
                  linkUrl={faq.linkUrl}
                />
              ))}
            </div>
          </section>
          <FAQAside />
        </main>
        <Footer />
      </div>
    </div>
  );
}

