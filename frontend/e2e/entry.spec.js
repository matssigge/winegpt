import { test, expect } from "playwright/test"

test("users can create an entry and see it in history", async ({ page }) => {
  const stamp = Date.now()
  const email = `entry-${stamp}@example.com`
  const collectionName = `Cellar ${stamp}`

  await page.goto("/")
  await expect(page.getByRole("heading", { name: "Welcome back" })).toBeVisible()
  await page.getByRole("button", { name: "Sign up" }).click()
  await page.getByLabel("Full name").fill("Entry User")
  await page.getByLabel("Email").fill(email)
  await page.getByLabel("Password").fill("password123")
  await page.getByRole("button", { name: "Create account" }).click()

  await expect(page.getByText(`Signed in as ${email}.`)).toBeVisible()
  await page.getByLabel("New collection").fill(collectionName)
  await page.getByRole("button", { name: "Create collection" }).click()
  await expect(page.getByRole("heading", { name: collectionName })).toBeVisible()

  await page.getByRole("button", { name: "Add entry" }).click()
  await page.getByLabel("Wine name").fill("Taganan")
  await page.getByLabel("Producer").fill("Envinate")
  await page.getByLabel("Vintage").fill("2022")
  await page.getByLabel("Consumed at").fill("2025-01-15T19:30")
  await page.getByLabel("Venue").fill("Home")
  await page.getByLabel("Location").fill("Stockholm")
  await page.getByLabel("Pairing notes").fill("Roast chicken")
  await page.getByLabel("Tasting notes").fill("Salty and bright")
  await page.getByLabel("Rating").fill("4")
  await page.getByRole("button", { name: "Save entry" }).click()

  await expect(page.getByRole("button", { name: "Add entry" })).toBeVisible()
  await expect(page.getByText("Envinate Taganan")).toBeVisible()
  await expect(page.getByText("2022 · Stockholm · Home")).toBeVisible()
  await expect(page.getByText("Envinate · Taganan · 2022")).toBeVisible()
  await expect(page.getByRole("definition").filter({ hasText: "Salty and bright" })).toBeVisible()
  await expect(page.getByRole("definition").filter({ hasText: "Roast chicken" })).toBeVisible()
  await expect(page.getByText("Rating 4/5")).toBeVisible()

  await page.reload()
  await expect(page.getByText("Envinate Taganan")).toBeVisible()
  await expect(page.getByText("Envinate · Taganan · 2022")).toBeVisible()
  await expect(page.getByText("Rating 4/5")).toBeVisible()
})
