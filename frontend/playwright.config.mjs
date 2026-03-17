import { tmpdir } from "node:os"
import { join } from "node:path"

export default {
  testDir: "./e2e",
  timeout: 30_000,
  outputDir: join(tmpdir(), "wine-playwright"),
  use: {
    baseURL: "http://frontend:5273",
    headless: true
  }
}
