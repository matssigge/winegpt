import { defineConfig } from "vite"
import rescript from "@jihchi/vite-plugin-rescript"

export default defineConfig({
  plugins: [rescript()],
  server: {
    port: 5273
  }
})
