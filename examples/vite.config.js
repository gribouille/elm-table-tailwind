import { defineConfig } from 'vite'
import elmPlugin from 'vite-plugin-elm'

export default defineConfig({
  base: '',
  plugins: [
    elmPlugin(),
  ],
  server: {
    proxy: {
      '/api2': {
        target: 'http://0.0.0.0:4000',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api2/, ''),
      },
      '/api': 'https://reqres.in'
    }
  }
})