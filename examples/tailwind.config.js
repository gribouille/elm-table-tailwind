const colors = require('tailwindcss/colors')

module.exports = {
  content: [
    './src/**/*',
    '../src/**/*',
    '../styles/**/*',
  ],
  theme: {
    extend: {},
    colors: {
      ...colors,
      transparent: 'transparent',
      current: 'currentColor'
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms'),
  ],
}
