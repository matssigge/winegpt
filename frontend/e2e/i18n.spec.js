import { test, expect } from "playwright/test"

test("a user can switch to Swedish, reload, and switch back to browser default", async ({ page }) => {
  const stamp = Date.now()
  const email = `i18n-${stamp}@example.com`

  await page.goto("/")
  await page.getByRole("button", { name: "Sign up" }).click()
  await page.getByLabel("Full name").fill("I18n User")
  await page.getByLabel("Email").fill(email)
  await page.getByLabel("Password").fill("password123")
  await page.getByRole("button", { name: "Create account" }).click()

  await expect(page.getByRole("heading", { name: "Wines", level: 1 })).toBeVisible()

  await page.getByRole("button", { name: "Open menu" }).click()
  await page.getByLabel("Svenska").check()
  await expect(page.getByRole("heading", { name: "Viner", level: 1 })).toBeVisible()
  await expect(page.getByRole("button", { name: "Logga ut" })).toBeVisible()

  await page.reload()
  await expect(page.getByRole("heading", { name: "Viner", level: 1 })).toBeVisible()

  await page.getByRole("button", { name: "Öppna meny" }).click()
  await page.getByLabel("Använd webbläsarens språk").check()
  await expect(page.getByRole("heading", { name: "Wines", level: 1 })).toBeVisible()
})
