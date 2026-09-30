import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');

  return {
    plugins: [
      react(),
      VitePWA({
        registerType: 'autoUpdate',
        injectRegister: 'auto',
        includeAssets: ['favicon.svg', 'apple-touch-icon.png'],
        manifest: {
          name: 'PulseTune',
          short_name: 'PulseTune',
          start_url: '/',
          display: 'standalone',
          background_color: '#0f172a',
          theme_color: '#0f172a',
          description: 'Heart-rate adaptive Spotify workout controller',
          icons: [
            {
              src: '/pwa-icon-192.png',
              sizes: '192x192',
              type: 'image/png'
            },
            {
              src: '/pwa-icon-512.png',
              sizes: '512x512',
              type: 'image/png'
            }
          ]
        }
      })
    ],
    server: {
      port: 5173
    },
    define: {
      __APP_VERSION__: JSON.stringify(env.npm_package_version ?? '0.1.0')
    }
  };
});
