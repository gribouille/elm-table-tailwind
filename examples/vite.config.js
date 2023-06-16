import { defineConfig } from 'vite'
import elmPlugin from 'vite-plugin-elm'

export default defineConfig({
  // base: '',
  plugins: [
    elmPlugin(),
  ],
  server: {
    proxy: {
      '/api': {
        target: 'https://reqres.in',
        pathRewrite: {
          '^/api': '/api'
        },
        changeOrigin: true,
        secure: false
      }
    }
  }
})