const jsonHeaders = {
  "content-type": "application/json"
}

async function request(path, options = {}) {
  const response = await fetch(path, options)
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
