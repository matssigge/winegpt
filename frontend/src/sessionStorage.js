const sessionTokenKey = "wine.sessionToken"

export function loadSessionToken() {
  return window.localStorage.getItem(sessionTokenKey)
}

export function saveSessionToken(token) {
  window.localStorage.setItem(sessionTokenKey, token)
}

export function clearSessionToken() {
  window.localStorage.removeItem(sessionTokenKey)
}
