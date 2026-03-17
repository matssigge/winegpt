import { tmpdir } from "node:os"
import { join } from "node:path"

export default {
  testDir: "./e2e",
  timeout: 30_000,
  outputDir: join(tmpdir(), "wine-playwright"),
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL ?? "http://frontend:4173",
    headless: true
  }
}
