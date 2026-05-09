import { test, expect } from "playwright/test"

test("hash routing keeps deep links and back navigation", async ({ page }) => {
  const stamp = Date.now()
  const email = `routing-${stamp}@example.com`

  await page.goto("/")
  await page.getByRole("button", { name: "Sign up" }).click()
  await page.getByLabel("Full name").fill("Routing User")
  await page.getByLabel("Email").fill(email)
  await page.getByLabel("Password").fill("password123")
  await page.getByRole("button", { name: "Create account" }).click()
  await expect(page.getByRole("heading", { name: "Wines", level: 1 })).toBeVisible()

  await page.getByRole("button", { name: "Add wine" }).click()
  await page.getByLabel("Wine name").fill("Trimbach Riesling")
  await page.getByLabel("Producer").fill("Trimbach")
  await page.getByLabel("Style").fill("White")
  await page.getByLabel("Grape").fill("Riesling")
  await page.getByLabel("Region").fill("Alsace")
  await page.getByLabel("Country").fill("France")
  await page.getByLabel("Vintage").fill("2020")
  await page.getByRole("button", { name: "Save wine" }).click()

  await expect(page).toHaveURL(/#\/wines\/\d+$/)
  const wineUrl = page.url()

  await page.goto("/")
  await page.goto(wineUrl)
  await expect(page.getByRole("heading", { name: /Trimbach Riesling/, level: 2 })).toBeVisible()

  await page.goBack()
  await expect(page.getByRole("heading", { name: "Wines", level: 1 })).toBeVisible()
})

test("search and filter icons toggle their panels", async ({ page }) => {
  const stamp = Date.now()
  const email = `filter-${stamp}@example.com`

  await page.goto("/")
  await page.getByRole("button", { name: "Sign up" }).click()
  await page.getByLabel("Full name").fill("Filter User")
  await page.getByLabel("Email").fill(email)
  await page.getByLabel("Password").fill("password123")
  await page.getByRole("button", { name: "Create account" }).click()
  await expect(page.getByRole("heading", { name: "Wines", level: 1 })).toBeVisible()

  await expect(page.getByRole("textbox", { name: "Search wines" })).toHaveCount(0)
  await page.getByRole("button", { name: "Search wines" }).click()
  await expect(page.getByRole("textbox", { name: "Search wines" })).toBeVisible()
  await page.getByRole("button", { name: "Close search" }).click()
  await expect(page.getByRole("textbox", { name: "Search wines" })).toHaveCount(0)

  await expect(page.getByRole("button", { name: "All wines" })).toHaveCount(0)
  await page.getByRole("button", { name: "Filter wines" }).click()
  await expect(page.getByRole("button", { name: "All wines" })).toBeVisible()
  await page.getByRole("button", { name: "Close filter" }).click()
  await expect(page.getByRole("button", { name: "All wines" })).toHaveCount(0)
})
