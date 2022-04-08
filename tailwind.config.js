const colors = require('tailwindcss/colors')

module.exports = {
  content: [
    './src/**/*',
    './styles/**/*'
  ],
  theme: {
    extend: {},
    colors: {
      ...colors,
      transparent: 'transparent',
      current: 'currentColor'
    },
  },
  plugins: [],
}
