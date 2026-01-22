import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import fs from 'fs'

export default defineConfig({
  plugins: [vue()],
  server: {
    https: {
      key: fs.readFileSync('./nginx.key'),
      cert: fs.readFileSync('./nginx.crt'),
    },
    host: true,
    port: 5173,
    allowedHosts: true
  },
})