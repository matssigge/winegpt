const jsonHeaders = {
  "content-type": "application/json"
}

function defaultApiBaseUrl() {
  if (typeof window === "undefined") {
    return "http://127.0.0.1:3000"
  }

  const { hostname, protocol } = window.location
  const host = hostname === "frontend" ? "backend" : hostname

  return `${protocol}//${host}:3000`
}

const apiBaseUrl =
  import.meta.env.VITE_API_BASE_URL?.trim() || defaultApiBaseUrl()

async function request(path, options = {}) {
  const response = await fetch(`${apiBaseUrl}${path}`, options)
  const body = await response.text()

  if (!response.ok) {
    let error = "request_failed"

    try {
      const parsed = JSON.parse(body)
      error = parsed.error ?? error
    } catch {
      error = "request_failed"
    }

    throw new Error(error)
  }

  return body
}

export function register(email, fullName, password) {
  return request("/api/auth/register", {
    method: "POST",
    headers: jsonHeaders,
    body: JSON.stringify({
      email,
      full_name: fullName,
      password
    })
  })
}

export function login(email, password) {
  return request("/api/auth/login", {
    method: "POST",
    headers: jsonHeaders,
    body: JSON.stringify({
      email,
      password
    })
  })
}

export function me(token) {
  return request("/api/me", {
    headers: {
      authorization: `Bearer ${token}`
    }
  })
}
