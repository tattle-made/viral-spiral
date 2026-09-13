import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist',
  },
  server: {
    proxy: {
      '/socket': {
        target: 'http://localhost:4000',
        ws: true,
      },
      '/images': 'http://localhost:4000',
    }
  }
})
