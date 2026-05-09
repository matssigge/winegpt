import { test } from "node:test"
import assert from "node:assert/strict"
import { en, sv } from "./Translations.bs.js"

// `en` and `sv` are top-level `let` bindings in Translations.res and are
// exported as named JS bindings — we use them directly rather than calling
// `pick()`, which takes a variant value that's awkward to construct from JS.

test("English occasionCount handles 0/1/2/many", () => {
  assert.equal(en.occasionCount(0), "0 occasions")
  assert.equal(en.occasionCount(1), "1 occasion")
  assert.equal(en.occasionCount(2), "2 occasions")
  assert.equal(en.occasionCount(7), "7 occasions")
})

test("Swedish occasionCount handles 0/1/2/many", () => {
  assert.equal(sv.occasionCount(0), "0 tillfällen")
  assert.equal(sv.occasionCount(1), "1 tillfälle")
  assert.equal(sv.occasionCount(2), "2 tillfällen")
  assert.equal(sv.occasionCount(7), "7 tillfällen")
})

test("English entryCount handles 0/1/many", () => {
  assert.equal(en.entryCount(0), "0 entries")
  assert.equal(en.entryCount(1), "1 entry")
  assert.equal(en.entryCount(5), "5 entries")
})

test("Swedish entryCount handles 0/1/many", () => {
  assert.equal(sv.entryCount(0), "0 anteckningar")
  assert.equal(sv.entryCount(1), "1 anteckning")
  assert.equal(sv.entryCount(5), "5 anteckningar")
})

test("rating renders consistently in both locales", () => {
  assert.equal(en.rating(4), "Rating 4/5")
  assert.equal(sv.rating(4), "Betyg 4/5")
})

test("filteredOf renders the visible/total counts", () => {
  assert.equal(en.filteredOf(1, 3), "1 of 3 wines")
  assert.equal(sv.filteredOf(1, 3), "1 av 3 viner")
})
