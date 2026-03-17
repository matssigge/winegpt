import { defineConfig } from "vite"
import rescript from "@jihchi/vite-plugin-rescript"
import tailwindcss from "@tailwindcss/vite"

export default defineConfig({
  plugins: [tailwindcss(), rescript()],
  server: {
    port: 5273,
    allowedHosts: ["frontend"]
  }
})
