import { test, expect } from "playwright/test"

test("user can sign up and restore session", async ({ page }) => {
  const email = `mats-${Date.now()}@example.com`

  await page.goto("/")
  await expect(page.getByRole("heading", { name: "Welcome back" })).toBeVisible()
  await page.getByRole("button", { name: "Sign up" }).click()
  await page.getByLabel("Full name").fill("Mats")
  await page.getByLabel("Email").fill(email)
  await page.getByLabel("Password").fill("password123")
  await page.getByRole("button", { name: "Create account" }).click()
  await expect(page.getByText(`Signed in as ${email}.`)).toBeVisible()
  await page.reload()
  await expect(page.getByText(`Signed in as ${email}.`)).toBeVisible()
})
