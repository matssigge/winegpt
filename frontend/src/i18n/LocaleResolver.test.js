import { test } from "node:test"
import assert from "node:assert/strict"
import { resolve } from "./LocaleResolver.bs.js"
import { toCode } from "./AppLocale.bs.js"

// Compare via string codes so we don't depend on ReScript's internal variant encoding.
const code = (navigatorLanguage, override) => toCode(resolve(navigatorLanguage, override))

test("override always wins, regardless of navigator language", () => {
  assert.equal(code("en-US", "sv"), "sv")
  assert.equal(code("sv-SE", "en"), "en")
  assert.equal(code(undefined, "sv"), "sv")
})

test("no override + sv-prefixed navigator language → sv", () => {
  assert.equal(code("sv", undefined), "sv")
  assert.equal(code("sv-SE", undefined), "sv")
  assert.equal(code("sv-FI", undefined), "sv")
  assert.equal(code("SV-se", undefined), "sv")
})

test("no override + non-sv navigator language → en", () => {
  assert.equal(code("en-US", undefined), "en")
  assert.equal(code("en", undefined), "en")
  assert.equal(code("de-DE", undefined), "en")
  assert.equal(code("fr", undefined), "en")
})

test("no override + missing navigator language → en", () => {
  assert.equal(code(undefined, undefined), "en")
})

test("unrecognized override falls through to navigator detection", () => {
  assert.equal(code("sv-SE", "garbage"), "sv")
  assert.equal(code("en-US", "garbage"), "en")
})
