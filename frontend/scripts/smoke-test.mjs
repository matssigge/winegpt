import { existsSync, readFileSync } from "node:fs"
import { resolve } from "node:path"

const requiredFiles = [
  "index.html",
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

console.log("frontend smoke test passed")
