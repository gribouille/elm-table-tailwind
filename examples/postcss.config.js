const NODE_ENV = process.env.npm_lifecycle_event

module.exports = {
  plugins: NODE_ENV === 'build' ? [
    require('postcss-import'),
    require('tailwindcss'),
    require('autoprefixer'),
    require('cssnano'),
  ] : [
    require('postcss-import'),
    require('tailwindcss'),
    require('autoprefixer'),
  ]
}