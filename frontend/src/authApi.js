import { authHeaders, jsonHeaders, request } from "./apiClient.js"

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
    headers: authHeaders(token)
  })
}
