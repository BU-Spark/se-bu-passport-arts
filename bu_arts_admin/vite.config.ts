import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api/bu-events': {
        target: 'https://www.bu.edu',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api\/bu-events/, '/phpbin/calendar/rpc/events.php'),
      },
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './setupTests.ts',
  },
});