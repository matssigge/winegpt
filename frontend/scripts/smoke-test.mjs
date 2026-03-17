import { existsSync, readFileSync } from "node:fs"
import { resolve } from "node:path"

const requiredFiles = [
  "index.html",
  "playwright.config.mjs",
  "rescript.json",
  "src/App.res",
  "src/Main.res",
  "vite.config.mjs"
]

for (const file of requiredFiles) {
  if (!existsSync(resolve(file))) {
    throw new Error(`Missing required frontend file: ${file}`)
  }
}

const packageJson = JSON.parse(readFileSync(resolve("package.json"), "utf8"))

if (packageJson.scripts?.build !== "rescript build && vite build") {
  throw new Error("Unexpected frontend build script")
}

if (packageJson.scripts?.preview !== "vite preview") {
  throw new Error("Unexpected frontend preview script")
}

if (!packageJson.devDependencies?.tailwindcss) {
  throw new Error("Missing tailwindcss dev dependency")
}

if (!packageJson.devDependencies?.["@tailwindcss/vite"]) {
  throw new Error("Missing @tailwindcss/vite dev dependency")
}

if (!packageJson.devDependencies?.playwright) {
  throw new Error("Missing playwright dev dependency")
}

if (packageJson.scripts?.["test:e2e"] !== "playwright test") {
  throw new Error("Unexpected frontend e2e test script")
}

const playwrightConfig = readFileSync(resolve("playwright.config.mjs"), "utf8")

if (!playwrightConfig.includes('outputDir: join(tmpdir(), "wine-playwright")')) {
  throw new Error("Playwright artifacts should be written to a temp directory")
}

console.log("frontend smoke test passed")
