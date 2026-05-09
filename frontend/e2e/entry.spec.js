import { test, expect } from "playwright/test"

test("a user can add a wine and record an occasion", async ({ page }) => {
  const stamp = Date.now()
  const email = `entry-${stamp}@example.com`

  await page.goto("/")
  await page.getByRole("button", { name: "Sign up" }).click()
  await page.getByLabel("Full name").fill("Entry User")
  await page.getByLabel("Email").fill(email)
  await page.getByLabel("Password").fill("password123")
  await page.getByRole("button", { name: "Create account" }).click()

  await expect(page.getByRole("heading", { name: "Wines", level: 1 })).toBeVisible()

  await page.getByRole("button", { name: "Add wine" }).click()
  await page.getByLabel("Wine name").fill("Tondonia")
  await page.getByLabel("Producer").fill("Lopez de Heredia")
  await page.getByLabel("Style").fill("Red")
  await page.getByLabel("Grape").fill("Tempranillo")
  await page.getByLabel("Region").fill("Rioja")
  await page.getByLabel("Country").fill("Spain")
  await page.getByLabel("Vintage").fill("2011")
  await page.getByRole("button", { name: "Save wine" }).click()

  await expect(page).toHaveURL(/#\/wines\/\d+$/)
  await expect(page.getByRole("heading", { name: /Lopez de Heredia Tondonia/, level: 2 })).toBeVisible()

  await page.getByRole("button", { name: "+ Add occasion" }).click()
  await page.getByRole("button", { name: "Selected wine" }).click()
  await page.getByLabel("Consumed at").fill("2026-01-15T19:30")
  await page.getByLabel("Venue").fill("Home")
  await page.getByLabel("Location").fill("Stockholm")
  await page.getByLabel("Pairing notes").fill("Roast chicken")
  await page.getByLabel("Tasting notes").fill("Salty and bright")
  await page.getByLabel("Rating").fill("4")
  await page.getByRole("button", { name: "Save entry" }).click()

  await expect(page).toHaveURL(/#\/wines\/\d+$/)
  await expect(page.getByText("2026-01-15", { exact: false }).first()).toBeVisible()
  await expect(page.getByText("Stockholm", { exact: false })).toBeVisible()

  await page.getByRole("button", { name: "Back to wines" }).click()
  await expect(page).toHaveURL(/#\/$/)
  await expect(page.getByRole("heading", { name: "Wines", level: 1 })).toBeVisible()
  await expect(page.getByText("Lopez de Heredia Tondonia", { exact: false })).toBeVisible()
})
