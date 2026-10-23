/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0fdfc',
          100: '#ccfbf6',
          200: '#99f6ed',
          300: '#5eeade',
          400: '#2dd4c4',
          500: '#0fa3a3',
          600: '#0d8585',
          700: '#0f6b6b',
          800: '#115454',
          900: '#134646',
        },
        accent: {
          50: '#fff7ed',
          100: '#ffedd5',
          200: '#fed7aa',
          300: '#fdba74',
          400: '#fb923c',
          500: '#f97316',
          600: '#ea580c',
          700: '#c2410c',
          800: '#9a3412',
          900: '#7c2d12',
        },
      },
      fontFamily: {
        sans: ['Inter', 'Noto Sans Khmer', 'Battambang', 'system-ui', 'sans-serif'],
        khmer: ['Noto Sans Khmer', 'Battambang', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
