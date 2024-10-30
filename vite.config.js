import { fileURLToPath, URL } from 'node:url';

import vue from '@vitejs/plugin-vue';
import { defineConfig } from 'vite';
import vueDevtools from 'vite-plugin-vue-devtools';



// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    vueDevtools(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  // server: {
  //   host: true,
  //   port: 8080,
  // }

})
