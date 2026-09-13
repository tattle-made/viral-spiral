export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        brand: '#FD4F00',
        'blue-dark': '#5fa8db',
        'blue-light': '#a3ccea',
        'red-dark': '#ff7783',
        'red-light': '#ffb19b',
        'yellow-dark': '#ff9d00',
        'yellow-light': '#ffd082',
        'accent-1': '#514E80',
        'accent-2': '#7F7AB0',
        'accent-3': '#252653',
        'neutral-1': '#E68BBA',
        'neutral-2': '#856993',
        'neutral-3': '#EDC9C4',
        'neutral-4': '#70234B',
        'textcolor-light': '#293241',
        'textcolor-dark': '#edc9c4',
      },
      fontFamily: {
        sans: ['"Averia Libre"', 'system-ui', 'sans-serif'],
      },
      keyframes: {
        wiggle: {
          '0%':   { transform: 'scale(1)' },
          '30%':  { transform: 'scale(1.45)' },
          '60%':  { transform: 'scale(0.88)' },
          '100%': { transform: 'scale(1)' },
        },
      },
      animation: {
        wiggle: 'wiggle 0.45s ease-in-out',
      },
    },
  },
  plugins: [],
}
