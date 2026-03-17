import { test, expect } from "playwright/test"

test("user can sign up and restore session", async ({ page }) => {
  const email = `mats-${Date.now()}@example.com`
  const collectionName = `Weekend wines ${Date.now()}`

  await page.goto("/")
  await expect(page.getByRole("heading", { name: "Welcome back" })).toBeVisible()
  await page.getByRole("button", { name: "Sign up" }).click()
  await page.getByLabel("Full name").fill("Mats")
  await page.getByLabel("Email").fill(email)
  await page.getByLabel("Password").fill("password123")
  await page.getByRole("button", { name: "Create account" }).click()
  await expect(page.getByText(`Signed in as ${email}.`)).toBeVisible()
  await expect(page.getByRole("heading", { name: "No collections yet" })).toBeVisible()
  await page.getByLabel("New collection").fill(collectionName)
  await page.getByRole("button", { name: "Create collection" }).click()
  await expect(page.getByText(collectionName)).toBeVisible()
  await expect(page.getByText("Selected")).toBeVisible()
  await page.reload()
  await expect(page.getByText(`Signed in as ${email}.`)).toBeVisible()
  await expect(page.getByText(collectionName)).toBeVisible()
  await expect(page.getByText("Selected")).toBeVisible()
})
