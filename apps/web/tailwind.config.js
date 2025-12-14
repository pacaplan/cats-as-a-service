/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: '#fbf8ff',
        foreground: '#1f1b24',
        border: '#00000000',
        input: '#ffffff',
        primary: {
          DEFAULT: '#ff8c42',
          foreground: '#ffffff',
        },
        secondary: {
          DEFAULT: '#c8b7ff',
          foreground: '#2b1b47',
        },
        muted: {
          DEFAULT: '#f2edf7',
          foreground: '#6b6173',
        },
        success: {
          DEFAULT: '#7de0a8',
          foreground: '#07321a',
        },
        accent: {
          DEFAULT: '#ffd9b5',
          foreground: '#4b2a00',
        },
        destructive: {
          DEFAULT: '#ff6b6b',
          foreground: '#ffffff',
        },
        warning: {
          DEFAULT: '#ffd166',
          foreground: '#332200',
        },
        card: {
          DEFAULT: '#ffffff',
          foreground: '#1f1b24',
        },
        sidebar: {
          DEFAULT: '#f7f5fb',
          foreground: '#453b4a',
          primary: '#fff0e6',
          'primary-foreground': '#663a12',
        },
      },
      borderRadius: {
        sm: '4px',
        DEFAULT: '6px',
        md: '6px',
        lg: '8px',
        xl: '12px',
      },
      keyframes: {
        shimmer: {
          '0%': { backgroundPosition: '-200px 0' },
          '100%': { backgroundPosition: '200px 0' },
        },
        pulse: {
          '0%': { transform: 'translateY(0)', opacity: '1' },
          '50%': { transform: 'translateY(-4px)', opacity: '0.6' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
      animation: {
        shimmer: 'shimmer 2s infinite',
        'pulse-dot': 'pulse 1.2s infinite ease-in-out',
      },
    },
  },
  plugins: [],
}
