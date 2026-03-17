import { authHeaders, jsonHeaders, request } from "./apiClient.js"

export function listCollections(token) {
  return request("/api/collections", {
    headers: authHeaders(token)
  })
}

export function createCollection(token, name) {
  return request("/api/collections", {
    method: "POST",
    headers: authHeaders(token, jsonHeaders),
    body: JSON.stringify({ name })
  })
}
