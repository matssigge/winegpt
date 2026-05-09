import { test } from "node:test"
import assert from "node:assert/strict"
import { existsSync, readFileSync } from "node:fs"
import { resolve } from "node:path"

const requiredFiles = [
  "index.html",
  "playwright.config.mjs",
  "rescript.json",
  "scripts/wait-for-url.mjs",
  "src/App.res",
  "src/Main.res",
  "src/router/Router.res",
  "src/screens/WineListScreen.res",
  "src/screens/WineDetailScreen.res",
  "src/screens/WineComposerScreen.res",
  "src/screens/EntryComposerScreen.res",
  "vite.config.mjs",
]

test("required frontend files exist", () => {
  for (const file of requiredFiles) {
    assert.ok(existsSync(resolve(file)), `missing required frontend file: ${file}`)
  }
})

test("package.json scripts and devDependencies are intact", () => {
  const packageJson = JSON.parse(readFileSync(resolve("package.json"), "utf8"))

  assert.equal(
    packageJson.scripts?.build,
    "rescript build -regen && rescript build && vite build",
    "unexpected frontend build script",
  )
  assert.equal(packageJson.scripts?.preview, "vite preview", "unexpected preview script")
  assert.equal(packageJson.scripts?.["test:e2e"], "playwright test", "unexpected e2e script")
  assert.ok(packageJson.devDependencies?.tailwindcss, "missing tailwindcss devDep")
  assert.ok(
    packageJson.devDependencies?.["@tailwindcss/vite"],
    "missing @tailwindcss/vite devDep",
  )
  assert.ok(packageJson.devDependencies?.playwright, "missing playwright devDep")
})

test("playwright config writes artifacts to a temp dir and reads PLAYWRIGHT_BASE_URL", () => {
  const playwrightConfig = readFileSync(resolve("playwright.config.mjs"), "utf8")
  assert.ok(
    playwrightConfig.includes('outputDir: join(tmpdir(), "wine-playwright")'),
    "playwright artifacts should be written to a temp directory",
  )
  assert.ok(
    playwrightConfig.includes("PLAYWRIGHT_BASE_URL"),
    "playwright base URL should be configurable",
  )
})
