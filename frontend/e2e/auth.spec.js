import { test, expect } from "playwright/test"

test("a user can register, reload, and log out", async ({ page }) => {
  const stamp = Date.now()
  const email = `auth-${stamp}@example.com`

  await page.goto("/")
  await expect(page.getByRole("heading", { name: "Welcome back" })).toBeVisible()
  await page.getByRole("button", { name: "Sign up" }).click()
  await page.getByLabel("Full name").fill("Auth User")
  await page.getByLabel("Email").fill(email)
  await page.getByLabel("Password").fill("password123")
  await page.getByRole("button", { name: "Create account" }).click()

  await expect(page.getByRole("heading", { name: "Wines", level: 1 })).toBeVisible()

  await page.reload()
  await expect(page.getByRole("heading", { name: "Wines", level: 1 })).toBeVisible()

  await page.getByRole("button", { name: "Open menu" }).click()
  await expect(page.getByText(email)).toBeVisible()
  await page.getByRole("button", { name: "Log out" }).click()
  await expect(page.getByRole("heading", { name: "Welcome back" })).toBeVisible()

  await page.getByLabel("Email").fill(email)
  await page.getByLabel("Password").fill("password123")
  await page.locator("form").getByRole("button", { name: "Log in" }).click()
  await expect(page.getByRole("heading", { name: "Wines", level: 1 })).toBeVisible()
})
