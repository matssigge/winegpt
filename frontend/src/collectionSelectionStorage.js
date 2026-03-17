const selectedCollectionIdKey = "wine.selectedCollectionId"

export function loadSelectedCollectionId() {
  const value = window.localStorage.getItem(selectedCollectionIdKey)

  if (!value) {
    return null
  }

  const parsed = Number.parseInt(value, 10)

  return Number.isNaN(parsed) ? null : parsed
}

export function saveSelectedCollectionId(collectionId) {
  window.localStorage.setItem(selectedCollectionIdKey, String(collectionId))
}

export function clearSelectedCollectionId() {
  window.localStorage.removeItem(selectedCollectionIdKey)
}
