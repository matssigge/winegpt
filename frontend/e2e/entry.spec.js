import { test, expect } from "playwright/test"

test("a user can add a wine and record an occasion with a date", async ({ page }) => {
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
  await expect(
    page.getByRole("heading", { name: /Lopez de Heredia Tondonia/, level: 2 }),
  ).toBeVisible()

  await page.getByRole("button", { name: "+ Add occasion" }).click()
  // The composer no longer has a Selected/Different toggle.
  await expect(page.getByRole("button", { name: "Selected wine" })).toHaveCount(0)
  // Date checkbox starts off; date input is not rendered.
  await expect(page.getByRole("checkbox", { name: "Specify date" })).not.toBeChecked()
  await expect(page.getByLabel("Consumed at")).toHaveCount(0)

  await page.getByLabel("Pairing notes").fill("Roast chicken")
  await page.getByLabel("Tasting notes").fill("Salty and bright")
  await page.getByLabel("Rating").fill("4")
  await page.getByRole("checkbox", { name: "Specify date" }).check()
  // Once toggled on, the date input should be pre-filled with today's date (YYYY-MM-DD).
  const today = new Date().toISOString().slice(0, 10)
  await expect(page.getByLabel("Consumed at")).toHaveValue(today)
  await page.getByLabel("Venue").fill("Home")
  await page.getByLabel("Location").fill("Stockholm")
  await page.getByRole("button", { name: "Save entry" }).click()

  await expect(page).toHaveURL(/#\/wines\/\d+$/)
  await expect(page.getByText(today, { exact: false }).first()).toBeVisible()
  await expect(page.getByText("Stockholm", { exact: false })).toBeVisible()
})

test("a user can record an occasion without a date", async ({ page }) => {
  const stamp = Date.now()
  const email = `entry-nodate-${stamp}@example.com`

  await page.goto("/")
  await page.getByRole("button", { name: "Sign up" }).click()
  await page.getByLabel("Full name").fill("Nodate User")
  await page.getByLabel("Email").fill(email)
  await page.getByLabel("Password").fill("password123")
  await page.getByRole("button", { name: "Create account" }).click()

  await page.getByRole("button", { name: "Add wine" }).click()
  await page.getByLabel("Wine name").fill("Selvapiana")
  await page.getByLabel("Producer").fill("Selvapiana")
  await page.getByLabel("Style").fill("Red")
  await page.getByLabel("Grape").fill("Sangiovese")
  await page.getByLabel("Region").fill("Tuscany")
  await page.getByLabel("Country").fill("Italy")
  await page.getByLabel("Vintage").fill("2019")
  await page.getByRole("button", { name: "Save wine" }).click()

  await page.getByRole("button", { name: "+ Add occasion" }).click()
  await page.getByLabel("Pairing notes").fill("Pasta")
  await page.getByRole("button", { name: "Save entry" }).click()

  // The occasion appears, but no date line is visible.
  await expect(page.getByText("Pasta", { exact: false })).toBeVisible()
})
