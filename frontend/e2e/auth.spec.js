import { test, expect } from "playwright/test"

test("users can share a collection", async ({ page }) => {
  const stamp = Date.now()
  const ownerEmail = `owner-${stamp}@example.com`
  const inviteeEmail = `invitee-${stamp}@example.com`
  const collectionName = `Weekend wines ${Date.now()}`

  await page.goto("/")
  await expect(page.getByRole("heading", { name: "Welcome back" })).toBeVisible()
  await page.getByRole("button", { name: "Sign up" }).click()
  await page.getByLabel("Full name").fill("Invitee")
  await page.getByLabel("Email").fill(inviteeEmail)
  await page.getByLabel("Password").fill("password123")
  await page.getByRole("button", { name: "Create account" }).click()
  await expect(page.getByText(`Signed in as ${inviteeEmail}.`)).toBeVisible()
  await page.getByRole("button", { name: "Log out" }).click()
  await expect(page.getByRole("heading", { name: "Welcome back" })).toBeVisible()

  await page.getByRole("button", { name: "Sign up" }).click()
  await page.getByLabel("Full name").fill("Mats")
  await page.getByLabel("Email").fill(ownerEmail)
  await page.getByLabel("Password").fill("password123")
  await page.getByRole("button", { name: "Create account" }).click()
  await expect(page.getByText(`Signed in as ${ownerEmail}.`)).toBeVisible()
  await expect(page.getByRole("heading", { name: "No collections yet" })).toBeVisible()
  await page.getByLabel("New collection").fill(collectionName)
  await page.getByRole("button", { name: "Create collection" }).click()
  await expect(page.getByRole("button", { name: collectionName })).toBeVisible()
  await expect(page.getByRole("heading", { name: collectionName })).toBeVisible()

  await page.getByLabel("Invite by email").fill(inviteeEmail)
  await page.getByRole("button", { name: "Invite" }).click()
  await expect(page.getByText(`Invited ${inviteeEmail}.`)).toBeVisible()

  await page.reload()
  await expect(page.getByText(`Signed in as ${ownerEmail}.`)).toBeVisible()
  await expect(page.getByRole("button", { name: collectionName })).toBeVisible()
  await expect(page.getByRole("heading", { name: collectionName })).toBeVisible()

  await page.getByRole("button", { name: "Log out" }).click()
  await expect(page.getByRole("heading", { name: "Welcome back" })).toBeVisible()

  await page.getByLabel("Email").fill(inviteeEmail)
  await page.getByLabel("Password").fill("password123")
  await page.locator("form").getByRole("button", { name: "Log in" }).click()
  await expect(page.getByText(`Signed in as ${inviteeEmail}.`)).toBeVisible()
  await expect(page.getByRole("button", { name: collectionName })).toBeVisible()
  await expect(page.getByRole("heading", { name: collectionName })).toBeVisible()
  await expect(page.getByText("You currently have member access to this collection.")).toBeVisible()
  await expect(page.getByLabel("Invite by email")).toHaveCount(0)
})
